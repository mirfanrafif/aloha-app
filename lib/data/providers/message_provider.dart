import 'dart:io';

import 'package:aloha/data/preferences/user_preferences.dart';
import 'package:aloha/data/response/contact.dart';
import 'package:aloha/data/service/message_service.dart';
import 'package:aloha/utils/api_response.dart';
import 'package:aloha/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/customer_message.dart';
import '../response/message.dart';

class MessageProvider extends ChangeNotifier {
  List<CustomerMessage> _customerMessage = [];

  final MessageService _messageService = MessageService();
  final UserPreferences _preferences = UserPreferences();

  List<CustomerMessage> get customerMessage =>
      List.unmodifiable(_customerMessage);

  String _token = "";
  int _id = 0;
  bool initDone = false;

  Future<ApiResponse<List<Contact>>> init() async {
    initDone = true;
    _token = _preferences.getToken();
    var user = _preferences.getUser();
    _id = user.id;
    setupSocket();
    return await getAllContact();
  }

  var _searchKeyword = "";

  String get searchKeyword => _searchKeyword;
  set searchKeyword(String newValue) {
    _searchKeyword = newValue;
    getAllContact();
    notifyListeners();
  }

  Future<ApiResponse<List<Customer>?>> searchNewCustomer(String keyword) async {
    return await _messageService.searchCustomerFromCrm(keyword, _token);
  }

  var chatLoading = false;

  List<Message> getMessageByCustomerId(int customerId) =>
      _customerMessage[findCustomerIndexById(customerId)].message;

  Future<ApiResponse<List<Contact>>> getAllContact() async {
    _customerMessage.clear();
    var value = await _messageService.getAllContact(_token, _searchKeyword);
    if (value.success && value.data != null) {
      mapContactToCustomerMessage(value.data!);
    }
    return value;
  }

  bool getIsAllLoaded(int customerId) {
    var index = findCustomerIndexById(customerId);
    return customerMessage[index].allLoaded;
  }

  void mapContactToCustomerMessage(List<Contact> contactList) {
    for (var contact in contactList) {
      _customerMessage.add(CustomerMessage(
          customer: contact.customer,
          message: contact.lastMessage != null ? [contact.lastMessage!] : [],
          unread: contact.unread));
    }
    notifyListeners();
  }

  void logout() {
    _customerMessage.clear();
    _preferences.logout();
    initDone = false;
    notifyListeners();
  }

  void setupSocket() {
    try {
      var socketClient = io(
          "https://" + baseUrl + "/messages",
          OptionBuilder()
              .setTransports(['websocket'])
              .enableReconnection()
              .build());

      socketClient.onConnectError((data) {
        if (data is WebSocketException) {
        } else if (data is SocketException) {
        } else {}
      });
      socketClient.onConnect((data) {
        var data = {'id': _id};
        socketClient.emit("join", jsonEncode(data));

        socketClient.on("message", (data) {
          var incomingMessage = Message.fromJson(jsonDecode(data as String));
          var customerIndex =
              findCustomerIndexById(incomingMessage.customer.id);
          if (customerIndex == -1) {
            _customerMessage = [
              CustomerMessage(
                  customer: incomingMessage.customer,
                  message: [incomingMessage],
                  unread: 1),
              ..._customerMessage
            ];
          } else {
            //mencari index pesan
            var messageIndex = customerMessage[customerIndex]
                .message
                .indexWhere((element) => element.id == incomingMessage.id);
            if (messageIndex == -1) {
              //menerima pesan baru
              customerMessage[customerIndex].message = [
                incomingMessage,
                ...customerMessage[customerIndex].message
              ];

              //update unread nya
              if (incomingMessage.fromMe) {
                customerMessage[customerIndex].unread = 0;
              } else {
                customerMessage[customerIndex].unread++;
              }
            } else {
              //bagian ini cuma buat update tracking
              customerMessage[customerIndex].message[messageIndex] =
                  incomingMessage;
            }
          }

          notifyListeners();
          return data;
        });
      });
    } catch (e) {}
  }

  bool getIsFirstLoad(int customerId) {
    var customerIndex = findCustomerIndexById(customerId);
    return _customerMessage[customerIndex].firstLoad;
  }

  void setFirstLoadDone(int customerId) {
    var customerIndex = _customerMessage
        .indexWhere((element) => element.customer.id == customerId);
    if (customerId > -1) {
      _customerMessage[customerIndex].firstLoad = false;
    }
  }

  void addPreviousMessage(int customerId, List<Message> messages) {
    var customerIndex = findCustomerIndexById(customerId);
    for (var item in messages) {
      var sameId = customerMessage[customerIndex]
          .message
          .indexWhere((element) => element.id == item.id);
      if (sameId == -1) {
        customerMessage[customerIndex].message.add(item);
      }
    }
  }

  void getPastMessages({required int customerId, bool loadMore = false}) async {
    var customerIndex = findCustomerIndexById(customerId);
    var messages = customerMessage[customerIndex].message;
    if (customerMessage[customerIndex].allLoaded) {
      return;
    }
    if (messages.isNotEmpty) {
      chatLoading = true;
      var lastMessageId = messages.last.id;
      var response = await _messageService.getPastMessages(
          customerId: customerId,
          loadMore: loadMore,
          lastMessageId: lastMessageId,
          token: _token);

      if (response.isNotEmpty) {
        addPreviousMessage(customerId, response);
      } else {
        customerMessage[customerIndex].allLoaded = true;
      }
      chatLoading = false;
      notifyListeners();
    }
  }

  int findCustomerIndexById(int customerId) {
    return _customerMessage
        .indexWhere((element) => element.customer.id == customerId);
  }

  void sendMessage({required String customerNumber, required String message}) {
    _messageService.sendMessage(
        customerNumber: customerNumber, message: message, token: _token);
  }

  void sendDocument({required File file, required String customerNumber}) {
    _messageService.sendDocument(
        file: file, customerNumber: customerNumber, token: _token);
  }

  Future<void> sendImage(
      {required XFile file,
      required String customerNumber,
      required String message}) async {
    await _messageService.sendImage(
        file: file,
        message: message,
        customerNumber: customerNumber,
        token: _token);
  }

  Future<ApiResponse<Customer?>> startConversation(int customerId) async {
    var response = await _messageService.startConversation(customerId, _token);
    if (response.success && response.data != null) {
      _customerMessage.add(
          CustomerMessage(customer: response.data!, message: [], unread: 0));
    }
    notifyListeners();
    return response;
  }
}
