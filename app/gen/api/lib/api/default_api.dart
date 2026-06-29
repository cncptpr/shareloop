//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class DefaultApi {
  DefaultApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Accept an offer
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] offerId (required):
  Future<Response> acceptOfferWithHttpInfo(int offerId,) async {
    // ignore: prefer_const_declarations
    final path = r'/offers/{offerId}/accept'
      .replaceAll('{offerId}', offerId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Accept an offer
  ///
  /// Parameters:
  ///
  /// * [int] offerId (required):
  Future<RentOffer?> acceptOffer(int offerId,) async {
    final response = await acceptOfferWithHttpInfo(offerId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RentOffer',) as RentOffer;
    
    }
    return null;
  }

  /// Confirm that borrowing happened
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  Future<Response> confirmBorrowWithHttpInfo(int requestId,) async {
    // ignore: prefer_const_declarations
    final path = r'/rent-requests/{requestId}/confirm-borrow'
      .replaceAll('{requestId}', requestId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Confirm that borrowing happened
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  Future<RentRequestDetail?> confirmBorrow(int requestId,) async {
    final response = await confirmBorrowWithHttpInfo(requestId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RentRequestDetail',) as RentRequestDetail;
    
    }
    return null;
  }

  /// Confirm item was returned
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  Future<Response> confirmReturnWithHttpInfo(int requestId,) async {
    // ignore: prefer_const_declarations
    final path = r'/rent-requests/{requestId}/confirm-return'
      .replaceAll('{requestId}', requestId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Confirm item was returned
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  Future<RentRequestDetail?> confirmReturn(int requestId,) async {
    final response = await confirmReturnWithHttpInfo(requestId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RentRequestDetail',) as RentRequestDetail;
    
    }
    return null;
  }

  /// Create a new item
  ///
  /// Creates a new item listing
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateItemRequest] createItemRequest (required):
  Future<Response> createItemWithHttpInfo(CreateItemRequest createItemRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/items';

    // ignore: prefer_final_locals
    Object? postBody = createItemRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Create a new item
  ///
  /// Creates a new item listing
  ///
  /// Parameters:
  ///
  /// * [CreateItemRequest] createItemRequest (required):
  Future<CreateItemResponse?> createItem(CreateItemRequest createItemRequest,) async {
    final response = await createItemWithHttpInfo(createItemRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateItemResponse',) as CreateItemResponse;
    
    }
    return null;
  }

  /// Make or counter an offer
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  ///
  /// * [CreateOfferRequest] createOfferRequest (required):
  Future<Response> createOfferWithHttpInfo(int requestId, CreateOfferRequest createOfferRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/rent-requests/{requestId}/offers'
      .replaceAll('{requestId}', requestId.toString());

    // ignore: prefer_final_locals
    Object? postBody = createOfferRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Make or counter an offer
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  ///
  /// * [CreateOfferRequest] createOfferRequest (required):
  Future<RentOffer?> createOffer(int requestId, CreateOfferRequest createOfferRequest,) async {
    final response = await createOfferWithHttpInfo(requestId, createOfferRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RentOffer',) as RentOffer;
    
    }
    return null;
  }

  /// Create or get existing open rent request
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<Response> createRentRequestWithHttpInfo(int itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/items/{itemId}/rent-requests'
      .replaceAll('{itemId}', itemId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Create or get existing open rent request
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<RentRequestDetail?> createRentRequest(int itemId,) async {
    final response = await createRentRequestWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RentRequestDetail',) as RentRequestDetail;
    
    }
    return null;
  }

  /// Decline seeding prompt
  ///
  /// Records that the user declined the seeding prompt. Sets the seeding timestamp without performing the actual seeding. Returns 400 if seeding is disabled. 
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> declineSeedWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/seed/decline';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Decline seeding prompt
  ///
  /// Records that the user declined the seeding prompt. Sets the seeding timestamp without performing the actual seeding. Returns 400 if seeding is disabled. 
  Future<SeedDatabase200Response?> declineSeed() async {
    final response = await declineSeedWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SeedDatabase200Response',) as SeedDatabase200Response;
    
    }
    return null;
  }

  /// Delete an item
  ///
  /// Delete an item listing. Only the owner can delete. Fails with 409 if the item has active rent requests.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<Response> deleteItemWithHttpInfo(int itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/items/{itemId}'
      .replaceAll('{itemId}', itemId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Delete an item
  ///
  /// Delete an item listing. Only the owner can delete. Fails with 409 if the item has active rent requests.
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<void> deleteItem(int itemId,) async {
    final response = await deleteItemWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Edit item images (reorder / delete)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  ///
  /// * [EditItemImagesRequest] editItemImagesRequest (required):
  Future<Response> editItemImagesWithHttpInfo(int itemId, EditItemImagesRequest editItemImagesRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/items/{itemId}/images'
      .replaceAll('{itemId}', itemId.toString());

    // ignore: prefer_final_locals
    Object? postBody = editItemImagesRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Edit item images (reorder / delete)
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  ///
  /// * [EditItemImagesRequest] editItemImagesRequest (required):
  Future<void> editItemImages(int itemId, EditItemImagesRequest editItemImagesRequest,) async {
    final response = await editItemImagesWithHttpInfo(itemId, editItemImagesRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get booked date ranges for an item
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<Response> getBookedDatesWithHttpInfo(int itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/items/{itemId}/booked-dates'
      .replaceAll('{itemId}', itemId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get booked date ranges for an item
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<List<DateRange>?> getBookedDates(int itemId,) async {
    final response = await getBookedDatesWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<DateRange>') as List)
        .cast<DateRange>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get featured items
  ///
  /// Returns a list of featured items
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [LatLng] latLng:
  Future<Response> getFeaturedItemsWithHttpInfo({ LatLng? latLng, }) async {
    // ignore: prefer_const_declarations
    final path = r'/featured-items';

    // ignore: prefer_final_locals
    Object? postBody = latLng;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get featured items
  ///
  /// Returns a list of featured items
  ///
  /// Parameters:
  ///
  /// * [LatLng] latLng:
  Future<List<ItemOverview>?> getFeaturedItems({ LatLng? latLng, }) async {
    final response = await getFeaturedItemsWithHttpInfo( latLng: latLng, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ItemOverview>') as List)
        .cast<ItemOverview>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get raw image data
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] imageId (required):
  Future<Response> getImageWithHttpInfo(String imageId,) async {
    // ignore: prefer_const_declarations
    final path = r'/images/{imageId}'
      .replaceAll('{imageId}', imageId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get raw image data
  ///
  /// Parameters:
  ///
  /// * [String] imageId (required):
  Future<String?> getImage(String imageId,) async {
    final response = await getImageWithHttpInfo(imageId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'String',) as String;
    
    }
    return null;
  }

  /// Get server info
  ///
  /// Returns server version, API version, and seeding status
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getInfoWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/info';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get server info
  ///
  /// Returns server version, API version, and seeding status
  Future<ServerInfo?> getInfo() async {
    final response = await getInfoWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ServerInfo',) as ServerInfo;
    
    }
    return null;
  }

  /// Get item details
  ///
  /// Returns full details for a single item
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<Response> getItemWithHttpInfo(int itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/items/{itemId}'
      .replaceAll('{itemId}', itemId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get item details
  ///
  /// Returns full details for a single item
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<ItemDetail?> getItem(int itemId,) async {
    final response = await getItemWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ItemDetail',) as ItemDetail;
    
    }
    return null;
  }

  /// Get item edit details (owner only)
  ///
  /// Returns full item details including location for the item owner
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<Response> getItemEditWithHttpInfo(int itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/items/{itemId}/edit'
      .replaceAll('{itemId}', itemId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get item edit details (owner only)
  ///
  /// Returns full item details including location for the item owner
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<ItemEditDetail?> getItemEdit(int itemId,) async {
    final response = await getItemEditWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ItemEditDetail',) as ItemEditDetail;
    
    }
    return null;
  }

  /// Get a single rent request with messages and offers
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  Future<Response> getRentRequestWithHttpInfo(int requestId,) async {
    // ignore: prefer_const_declarations
    final path = r'/rent-requests/{requestId}'
      .replaceAll('{requestId}', requestId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get a single rent request with messages and offers
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  Future<RentRequestDetail?> getRentRequest(int requestId,) async {
    final response = await getRentRequestWithHttpInfo(requestId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RentRequestDetail',) as RentRequestDetail;
    
    }
    return null;
  }

  /// List rent requests for current user
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getRentRequestsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/rent-requests';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// List rent requests for current user
  Future<List<RentRequestOverview>?> getRentRequests() async {
    final response = await getRentRequestsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<RentRequestOverview>') as List)
        .cast<RentRequestOverview>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get user's items
  ///
  /// Returns all items belonging to the specified user
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] userId (required):
  Future<Response> getUserItemsWithHttpInfo(int userId,) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{userId}/items'
      .replaceAll('{userId}', userId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get user's items
  ///
  /// Returns all items belonging to the specified user
  ///
  /// Parameters:
  ///
  /// * [int] userId (required):
  Future<List<ItemOverview>?> getUserItems(int userId,) async {
    final response = await getUserItemsWithHttpInfo(userId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ItemOverview>') as List)
        .cast<ItemOverview>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get user profile
  ///
  /// Returns public profile information for a user
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] userId (required):
  Future<Response> getUserProfileWithHttpInfo(int userId,) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{userId}/profile'
      .replaceAll('{userId}', userId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get user profile
  ///
  /// Returns public profile information for a user
  ///
  /// Parameters:
  ///
  /// * [int] userId (required):
  Future<UserProfile?> getUserProfile(int userId,) async {
    final response = await getUserProfileWithHttpInfo(userId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserProfile',) as UserProfile;
    
    }
    return null;
  }

  /// Get user ratings
  ///
  /// Returns all user ratings received by the specified user
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] userId (required):
  Future<Response> getUserRatingsWithHttpInfo(int userId,) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{userId}/ratings'
      .replaceAll('{userId}', userId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get user ratings
  ///
  /// Returns all user ratings received by the specified user
  ///
  /// Parameters:
  ///
  /// * [int] userId (required):
  Future<List<UserRatingDetail>?> getUserRatings(int userId,) async {
    final response = await getUserRatingsWithHttpInfo(userId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<UserRatingDetail>') as List)
        .cast<UserRatingDetail>()
        .toList(growable: false);

    }
    return null;
  }

  /// Login
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [LoginRequest] loginRequest (required):
  Future<Response> loginWithHttpInfo(LoginRequest loginRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/login';

    // ignore: prefer_final_locals
    Object? postBody = loginRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Login
  ///
  /// Parameters:
  ///
  /// * [LoginRequest] loginRequest (required):
  Future<LoginResult?> login(LoginRequest loginRequest,) async {
    final response = await loginWithHttpInfo(loginRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'LoginResult',) as LoginResult;
    
    }
    return null;
  }

  /// Logout
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> logoutWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/auth/logout';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Logout
  Future<void> logout() async {
    final response = await logoutWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Mark a rent request as read
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  Future<Response> markRentRequestReadWithHttpInfo(int requestId,) async {
    // ignore: prefer_const_declarations
    final path = r'/rent-requests/{requestId}/mark-read'
      .replaceAll('{requestId}', requestId.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Mark a rent request as read
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  Future<void> markRentRequestRead(int requestId,) async {
    final response = await markRentRequestReadWithHttpInfo(requestId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Refresh tokens
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RefreshRequest] refreshRequest (required):
  Future<Response> refreshWithHttpInfo(RefreshRequest refreshRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/refresh';

    // ignore: prefer_final_locals
    Object? postBody = refreshRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Refresh tokens
  ///
  /// Parameters:
  ///
  /// * [RefreshRequest] refreshRequest (required):
  Future<LoginResult?> refresh(RefreshRequest refreshRequest,) async {
    final response = await refreshWithHttpInfo(refreshRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'LoginResult',) as LoginResult;
    
    }
    return null;
  }

  /// Register a new user
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RegisterRequest] registerRequest (required):
  Future<Response> registerWithHttpInfo(RegisterRequest registerRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/register';

    // ignore: prefer_final_locals
    Object? postBody = registerRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Register a new user
  ///
  /// Parameters:
  ///
  /// * [RegisterRequest] registerRequest (required):
  Future<LoginResult?> register(RegisterRequest registerRequest,) async {
    final response = await registerWithHttpInfo(registerRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'LoginResult',) as LoginResult;
    
    }
    return null;
  }

  /// Search items
  ///
  /// Search items with filters
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ItemSearchRequest] itemSearchRequest:
  Future<Response> searchItemsWithHttpInfo({ ItemSearchRequest? itemSearchRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/items/search';

    // ignore: prefer_final_locals
    Object? postBody = itemSearchRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Search items
  ///
  /// Search items with filters
  ///
  /// Parameters:
  ///
  /// * [ItemSearchRequest] itemSearchRequest:
  Future<List<ItemOverview>?> searchItems({ ItemSearchRequest? itemSearchRequest, }) async {
    final response = await searchItemsWithHttpInfo( itemSearchRequest: itemSearchRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ItemOverview>') as List)
        .cast<ItemOverview>()
        .toList(growable: false);

    }
    return null;
  }

  /// Seed the database with demo data
  ///
  /// Triggers database seeding with demo data from the configured seeding directory. This will DELETE all existing data. Returns 400 if seeding is disabled (no valid seeding data found). **This is a development feature.** 
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> seedDatabaseWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/seed';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Seed the database with demo data
  ///
  /// Triggers database seeding with demo data from the configured seeding directory. This will DELETE all existing data. Returns 400 if seeding is disabled (no valid seeding data found). **This is a development feature.** 
  Future<SeedDatabase200Response?> seedDatabase() async {
    final response = await seedDatabaseWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SeedDatabase200Response',) as SeedDatabase200Response;
    
    }
    return null;
  }

  /// Send a message in a rent request chat
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  ///
  /// * [SendMessageRequest] sendMessageRequest (required):
  Future<Response> sendMessageWithHttpInfo(int requestId, SendMessageRequest sendMessageRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/rent-requests/{requestId}/messages'
      .replaceAll('{requestId}', requestId.toString());

    // ignore: prefer_final_locals
    Object? postBody = sendMessageRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Send a message in a rent request chat
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  ///
  /// * [SendMessageRequest] sendMessageRequest (required):
  Future<Message?> sendMessage(int requestId, SendMessageRequest sendMessageRequest,) async {
    final response = await sendMessageWithHttpInfo(requestId, sendMessageRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Message',) as Message;
    
    }
    return null;
  }

  /// Rate the borrowed item after return
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  ///
  /// * [SubmitItemRatingRequest] submitItemRatingRequest (required):
  Future<Response> submitItemRatingWithHttpInfo(int requestId, SubmitItemRatingRequest submitItemRatingRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/rent-requests/{requestId}/item-rating'
      .replaceAll('{requestId}', requestId.toString());

    // ignore: prefer_final_locals
    Object? postBody = submitItemRatingRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Rate the borrowed item after return
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  ///
  /// * [SubmitItemRatingRequest] submitItemRatingRequest (required):
  Future<ItemRating?> submitItemRating(int requestId, SubmitItemRatingRequest submitItemRatingRequest,) async {
    final response = await submitItemRatingWithHttpInfo(requestId, submitItemRatingRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ItemRating',) as ItemRating;
    
    }
    return null;
  }

  /// Rate the other participant after return
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  ///
  /// * [SubmitUserRatingRequest] submitUserRatingRequest (required):
  Future<Response> submitUserRatingWithHttpInfo(int requestId, SubmitUserRatingRequest submitUserRatingRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/rent-requests/{requestId}/user-rating'
      .replaceAll('{requestId}', requestId.toString());

    // ignore: prefer_final_locals
    Object? postBody = submitUserRatingRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Rate the other participant after return
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  ///
  /// * [SubmitUserRatingRequest] submitUserRatingRequest (required):
  Future<UserRating?> submitUserRating(int requestId, SubmitUserRatingRequest submitUserRatingRequest,) async {
    final response = await submitUserRatingWithHttpInfo(requestId, submitUserRatingRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserRating',) as UserRating;
    
    }
    return null;
  }

  /// Update an item
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  ///
  /// * [UpdateItemRequest] updateItemRequest (required):
  Future<Response> updateItemWithHttpInfo(int itemId, UpdateItemRequest updateItemRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/items/{itemId}'
      .replaceAll('{itemId}', itemId.toString());

    // ignore: prefer_final_locals
    Object? postBody = updateItemRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Update an item
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  ///
  /// * [UpdateItemRequest] updateItemRequest (required):
  Future<CreateItemResponse?> updateItem(int itemId, UpdateItemRequest updateItemRequest,) async {
    final response = await updateItemWithHttpInfo(itemId, updateItemRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CreateItemResponse',) as CreateItemResponse;
    
    }
    return null;
  }

  /// Update own profile
  ///
  /// Update name and/or bio for the authenticated user's profile
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] userId (required):
  ///
  /// * [UpdateUserProfileRequest] updateUserProfileRequest (required):
  Future<Response> updateUserProfileWithHttpInfo(int userId, UpdateUserProfileRequest updateUserProfileRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/users/{userId}/profile'
      .replaceAll('{userId}', userId.toString());

    // ignore: prefer_final_locals
    Object? postBody = updateUserProfileRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Update own profile
  ///
  /// Update name and/or bio for the authenticated user's profile
  ///
  /// Parameters:
  ///
  /// * [int] userId (required):
  ///
  /// * [UpdateUserProfileRequest] updateUserProfileRequest (required):
  Future<UserProfile?> updateUserProfile(int userId, UpdateUserProfileRequest updateUserProfileRequest,) async {
    final response = await updateUserProfileWithHttpInfo(userId, updateUserProfileRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserProfile',) as UserProfile;
    
    }
    return null;
  }

  /// Upload an image for an item
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  ///
  /// * [UploadItemImageRequest] uploadItemImageRequest (required):
  Future<Response> uploadItemImageWithHttpInfo(int itemId, UploadItemImageRequest uploadItemImageRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/items/{itemId}/images'
      .replaceAll('{itemId}', itemId.toString());

    // ignore: prefer_final_locals
    Object? postBody = uploadItemImageRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Upload an image for an item
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  ///
  /// * [UploadItemImageRequest] uploadItemImageRequest (required):
  Future<UploadItemImageResponse?> uploadItemImage(int itemId, UploadItemImageRequest uploadItemImageRequest,) async {
    final response = await uploadItemImageWithHttpInfo(itemId, uploadItemImageRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UploadItemImageResponse',) as UploadItemImageResponse;
    
    }
    return null;
  }

  /// Verify access token
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> verifyWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/auth/verify';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Verify access token
  Future<User?> verify() async {
    final response = await verifyWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'User',) as User;
    
    }
    return null;
  }
}
