import 'package:flutter_test/flutter_test.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/home/models/service_model.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/utils/helpers/payment_request_mapper.dart';

void main() {
  group('PaymentRequestMapper - fromQuickPayment Tests', () {
    final dummyCartItems = [
      CartItemModel(
        service: ServiceModel(
          id: 1,
          name: 'Haircut',
          charge: 45.0,
          beforeVat: 42.86,
          unitTax: 2.14,
        ),
        quantity: 1,
      ),
    ];

    test('should use finalTotal (tax-inclusive) for amount, NOT subTotal', () {
      final request = PaymentRequestMapper.fromQuickPayment(
        transactionId: 101,
        onlineBookingId: null,
        customerName: 'John Doe',
        customerNumber: '0501234567',
        subTotal: 42.86,
        taxTotal: 2.14,
        discount: 0.0,
        finalTotal: 45.00,
        cartItems: dummyCartItems,
        userId: 5,
        paymentMode: PaymentMode.Cash.name,
      );

      // Verify that the amount is 45.00 (tax included) and NOT 42.86
      expect(request.amount, equals([45.00]));
      expect(request.paymentStatus, equals('full'));
      expect(request.mode, equals(['Cash']));
      expect(request.collectedUserId, equals([5]));
      expect(request.subTotalValue, equals(42.86));
      expect(request.taxTotal, equals(2.14));
      expect(request.finalTotal, equals(45.00));
    });

    test('should correctly deduct discount from finalTotal', () {
      final request = PaymentRequestMapper.fromQuickPayment(
        transactionId: 102,
        onlineBookingId: null,
        customerName: 'Jane Doe',
        customerNumber: '0507654321',
        subTotal: 42.86,
        taxTotal: 2.14,
        discount: 5.0,
        finalTotal: 45.00,
        cartItems: dummyCartItems,
        userId: 5,
        paymentMode: PaymentMode.Card.name,
      );

      // 45.00 - 5.00 = 40.00
      expect(request.amount, equals([40.00]));
      expect(request.discount, equals(5.0));
      expect(request.mode, equals(['Card']));
    });

    test('should set amount to 0.0 and status to "unpaid" when mode is Unpaid', () {
      final request = PaymentRequestMapper.fromQuickPayment(
        transactionId: 103,
        onlineBookingId: null,
        customerName: 'Alex',
        customerNumber: '0500000000',
        subTotal: 42.86,
        taxTotal: 2.14,
        discount: 0.0,
        finalTotal: 45.00,
        cartItems: dummyCartItems,
        userId: 5,
        paymentMode: PaymentMode.Unpaid.name,
      );

      expect(request.amount, equals([0.0]));
      expect(request.paymentStatus, equals('unpaid'));
      expect(request.mode, equals(['Cash']));
    });
  });

  group('PaymentRequestMapper - fromSaveAndSettle Tests', () {
    test('should map total amount and empty modes list for initial settlement dialog', () {
      final dummyCartItems = [
        CartItemModel(
          service: ServiceModel(
            id: 2,
            name: 'Shave',
            charge: 21.0,
            beforeVat: 20.0,
            unitTax: 1.0,
          ),
          quantity: 1,
        ),
      ];

      final request = PaymentRequestMapper.fromSaveAndSettle(
        transactionId: 201,
        onlineBookingId: null,
        customerName: 'Customer',
        customerNumber: '0501112233',
        subTotal: 20.0,
        taxTotal: 1.0,
        total: 21.0,
        cartItems: dummyCartItems,
        userId: 3,
      );

      expect(request.amount, equals([21.0]));
      expect(request.finalTotal, equals(21.0));
      expect(request.mode, isEmpty);
      expect(request.serviceId, equals([2]));
      expect(request.collectedUserId, equals([3]));
    });
  });

  group('PaymentRequestMapper - fromSettlementForm Tests', () {
    test('should replicate collectedUserId for each payment mode', () {
      final request = PaymentRequestMapper.fromSettlementForm(
        paymentStatus: 'full',
        transactionId: 301,
        onlineBookingId: null,
        customerName: 'Split Customer',
        customerNumber: '0509998877',
        subTotal: 42.86,
        taxTotal: 2.14,
        discount: 0.0,
        finalTotal: 45.0,
        finalTotalbefore: 45.0,
        serviceId: [1],
        quantity: [1],
        rate: [45.0],
        taxAmount: [2.14],
        currency: ['AED'],
        amountTotal: [45.0],
        tax: [2.14],
        subTotalList: [45.0],
        isTip: [0],
        collectedUserId: [7],
        mode: ['Cash', 'Card'],
        amount: [20.0, 25.0],
        tenderCash: [20.0, 25.0],
        change: [0.0, 0.0],
      );

      expect(request.mode, equals(['Cash', 'Card']));
      expect(request.amount, equals([20.0, 25.0]));
      // collectedUserId must match mode.length
      expect(request.collectedUserId, equals([7, 7]));
    });
  });

  group('PaymentRequestMapper - fromBookingResponse Tests', () {
    test('should safely handle services with null id fallback to 0', () {
      final booking = BookingResponseModel(
        id: 401,
        customerName: 'Test Booking',
        customerNumber: '0501234567',
        subtotal: 50.0,
        taxTotal: 2.5,
        discount: 0.0,
        finalTotal: 52.5,
        userId: 10,
        payments: [],
      );

      final cartItems = [
        CartItemModel(
          service: ServiceModel(
            id: null,
            name: 'Custom Service',
            charge: 52.5,
          ),
          quantity: 1,
        ),
      ];

      final request = PaymentRequestMapper.fromBookingResponse(
        booking,
        cartItems: cartItems,
      );

      expect(request.serviceId, equals([0]));
      expect(request.finalTotal, equals(52.5));
      expect(request.collectedUserId, equals([10]));
    });
  });
}
