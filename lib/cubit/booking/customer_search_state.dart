  import 'package:equatable/equatable.dart';
  import 'package:sharp_cut/domain/booking/models/customer_suggestion_model.dart';

  abstract class CustomerSearchState extends Equatable {
    @override
    List<Object?> get props => [];
  }

  class CustomerSearchInitial extends CustomerSearchState {}

  class CustomerSearchLoading extends CustomerSearchState {}

  class CustomerSearchSuccess extends CustomerSearchState {
    final List<CustomerSuggestionModel> suggestions;
    CustomerSearchSuccess(this.suggestions);

    @override
    List<Object?> get props => [suggestions];
  }

  class CustomerSearchError extends CustomerSearchState {
    final String message;
    CustomerSearchError(this.message);

    @override
    List<Object?> get props => [message];
  }
