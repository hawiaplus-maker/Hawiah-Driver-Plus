abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressUpdate extends AddressState {}

class AddressLoading extends AddressState {}

class AddressCitiesLoaded extends AddressState {}

class AddressNeighborhoodsLoaded extends AddressState {}

class AddressDataLoaded extends AddressState {}

class AddressError extends AddressState {
  final String message;
  AddressError(this.message);
}
