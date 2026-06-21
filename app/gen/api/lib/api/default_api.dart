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
  Future<Response> acceptOfferWithHttpInfo(int offerId, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Accept an offer
  ///
  /// Parameters:
  ///
  /// * [int] offerId (required):
  Future<RentOffer?> acceptOffer(int offerId, { Future<void>? abortTrigger, }) async {
    final response = await acceptOfferWithHttpInfo(offerId, abortTrigger: abortTrigger,);
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
  Future<Response> confirmBorrowWithHttpInfo(int requestId, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Confirm that borrowing happened
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  Future<RentRequest?> confirmBorrow(int requestId, { Future<void>? abortTrigger, }) async {
    final response = await confirmBorrowWithHttpInfo(requestId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RentRequest',) as RentRequest;
    
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
  Future<Response> confirmReturnWithHttpInfo(int requestId, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Confirm item was returned
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  Future<RentRequest?> confirmReturn(int requestId, { Future<void>? abortTrigger, }) async {
    final response = await confirmReturnWithHttpInfo(requestId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RentRequest',) as RentRequest;
    
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
  Future<Response> createItemWithHttpInfo(CreateItemRequest createItemRequest, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Create a new item
  ///
  /// Creates a new item listing
  ///
  /// Parameters:
  ///
  /// * [CreateItemRequest] createItemRequest (required):
  Future<CreateItemResponse?> createItem(CreateItemRequest createItemRequest, { Future<void>? abortTrigger, }) async {
    final response = await createItemWithHttpInfo(createItemRequest, abortTrigger: abortTrigger,);
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
  Future<Response> createOfferWithHttpInfo(int requestId, CreateOfferRequest createOfferRequest, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Make or counter an offer
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  ///
  /// * [CreateOfferRequest] createOfferRequest (required):
  Future<RentOffer?> createOffer(int requestId, CreateOfferRequest createOfferRequest, { Future<void>? abortTrigger, }) async {
    final response = await createOfferWithHttpInfo(requestId, createOfferRequest, abortTrigger: abortTrigger,);
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
  Future<Response> createRentRequestWithHttpInfo(int itemId, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Create or get existing open rent request
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<RentRequest?> createRentRequest(int itemId, { Future<void>? abortTrigger, }) async {
    final response = await createRentRequestWithHttpInfo(itemId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RentRequest',) as RentRequest;
    
    }
    return null;
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
  Future<Response> editItemImagesWithHttpInfo(int itemId, EditItemImagesRequest editItemImagesRequest, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Edit item images (reorder / delete)
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  ///
  /// * [EditItemImagesRequest] editItemImagesRequest (required):
  Future<void> editItemImages(int itemId, EditItemImagesRequest editItemImagesRequest, { Future<void>? abortTrigger, }) async {
    final response = await editItemImagesWithHttpInfo(itemId, editItemImagesRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
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
  Future<Response> getFeaturedItemsWithHttpInfo({ LatLng? latLng, Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Get featured items
  ///
  /// Returns a list of featured items
  ///
  /// Parameters:
  ///
  /// * [LatLng] latLng:
  Future<List<FeaturedItem>?> getFeaturedItems({ LatLng? latLng, Future<void>? abortTrigger, }) async {
    final response = await getFeaturedItemsWithHttpInfo(latLng: latLng, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<FeaturedItem>') as List)
        .cast<FeaturedItem>()
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
  Future<Response> getImageWithHttpInfo(String imageId, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Get raw image data
  ///
  /// Parameters:
  ///
  /// * [String] imageId (required):
  Future<String?> getImage(String imageId, { Future<void>? abortTrigger, }) async {
    final response = await getImageWithHttpInfo(imageId, abortTrigger: abortTrigger,);
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

  /// Get item details
  ///
  /// Returns full details for a single item
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<Response> getItemWithHttpInfo(int itemId, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Get item details
  ///
  /// Returns full details for a single item
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<ItemDetail?> getItem(int itemId, { Future<void>? abortTrigger, }) async {
    final response = await getItemWithHttpInfo(itemId, abortTrigger: abortTrigger,);
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
  Future<Response> getItemEditWithHttpInfo(int itemId, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Get item edit details (owner only)
  ///
  /// Returns full item details including location for the item owner
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  Future<ItemEditDetail?> getItemEdit(int itemId, { Future<void>? abortTrigger, }) async {
    final response = await getItemEditWithHttpInfo(itemId, abortTrigger: abortTrigger,);
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
  Future<Response> getRentRequestWithHttpInfo(int requestId, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Get a single rent request with messages and offers
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  Future<RentRequest?> getRentRequest(int requestId, { Future<void>? abortTrigger, }) async {
    final response = await getRentRequestWithHttpInfo(requestId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RentRequest',) as RentRequest;
    
    }
    return null;
  }

  /// List rent requests for current user
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getRentRequestsWithHttpInfo({ Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// List rent requests for current user
  Future<List<RentRequest>?> getRentRequests({ Future<void>? abortTrigger, }) async {
    final response = await getRentRequestsWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<RentRequest>') as List)
        .cast<RentRequest>()
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
  Future<Response> loginWithHttpInfo(LoginRequest loginRequest, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Login
  ///
  /// Parameters:
  ///
  /// * [LoginRequest] loginRequest (required):
  Future<LoginResult?> login(LoginRequest loginRequest, { Future<void>? abortTrigger, }) async {
    final response = await loginWithHttpInfo(loginRequest, abortTrigger: abortTrigger,);
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
  Future<Response> logoutWithHttpInfo({ Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Logout
  Future<void> logout({ Future<void>? abortTrigger, }) async {
    final response = await logoutWithHttpInfo(abortTrigger: abortTrigger,);
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
  Future<Response> refreshWithHttpInfo(RefreshRequest refreshRequest, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Refresh tokens
  ///
  /// Parameters:
  ///
  /// * [RefreshRequest] refreshRequest (required):
  Future<LoginResult?> refresh(RefreshRequest refreshRequest, { Future<void>? abortTrigger, }) async {
    final response = await refreshWithHttpInfo(refreshRequest, abortTrigger: abortTrigger,);
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

  /// Send a message in a rent request chat
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  ///
  /// * [SendMessageRequest] sendMessageRequest (required):
  Future<Response> sendMessageWithHttpInfo(int requestId, SendMessageRequest sendMessageRequest, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Send a message in a rent request chat
  ///
  /// Parameters:
  ///
  /// * [int] requestId (required):
  ///
  /// * [SendMessageRequest] sendMessageRequest (required):
  Future<Message?> sendMessage(int requestId, SendMessageRequest sendMessageRequest, { Future<void>? abortTrigger, }) async {
    final response = await sendMessageWithHttpInfo(requestId, sendMessageRequest, abortTrigger: abortTrigger,);
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

  /// Update an item
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  ///
  /// * [UpdateItemRequest] updateItemRequest (required):
  Future<Response> updateItemWithHttpInfo(int itemId, UpdateItemRequest updateItemRequest, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Update an item
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  ///
  /// * [UpdateItemRequest] updateItemRequest (required):
  Future<CreateItemResponse?> updateItem(int itemId, UpdateItemRequest updateItemRequest, { Future<void>? abortTrigger, }) async {
    final response = await updateItemWithHttpInfo(itemId, updateItemRequest, abortTrigger: abortTrigger,);
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

  /// Upload an image for an item
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  ///
  /// * [UploadItemImageRequest] uploadItemImageRequest (required):
  Future<Response> uploadItemImageWithHttpInfo(int itemId, UploadItemImageRequest uploadItemImageRequest, { Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Upload an image for an item
  ///
  /// Parameters:
  ///
  /// * [int] itemId (required):
  ///
  /// * [UploadItemImageRequest] uploadItemImageRequest (required):
  Future<UploadItemImageResponse?> uploadItemImage(int itemId, UploadItemImageRequest uploadItemImageRequest, { Future<void>? abortTrigger, }) async {
    final response = await uploadItemImageWithHttpInfo(itemId, uploadItemImageRequest, abortTrigger: abortTrigger,);
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
  Future<Response> verifyWithHttpInfo({ Future<void>? abortTrigger, }) async {
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
      abortTrigger: abortTrigger,
    );
  }

  /// Verify access token
  Future<User?> verify({ Future<void>? abortTrigger, }) async {
    final response = await verifyWithHttpInfo(abortTrigger: abortTrigger,);
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
