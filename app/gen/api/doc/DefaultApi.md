# openapi.api.DefaultApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptOffer**](DefaultApi.md#acceptoffer) | **POST** /offers/{offerId}/accept | Accept an offer
[**confirmBorrow**](DefaultApi.md#confirmborrow) | **POST** /rent-requests/{requestId}/confirm-borrow | Confirm that borrowing happened
[**confirmReturn**](DefaultApi.md#confirmreturn) | **POST** /rent-requests/{requestId}/confirm-return | Confirm item was returned
[**createItem**](DefaultApi.md#createitem) | **POST** /items | Create a new item
[**createOffer**](DefaultApi.md#createoffer) | **POST** /rent-requests/{requestId}/offers | Make or counter an offer
[**createRentRequest**](DefaultApi.md#createrentrequest) | **POST** /items/{itemId}/rent-requests | Create or get existing open rent request
[**declineSeed**](DefaultApi.md#declineseed) | **POST** /seed/decline | Decline seeding prompt
[**editItemImages**](DefaultApi.md#edititemimages) | **PUT** /items/{itemId}/images | Edit item images (reorder / delete)
[**getFeaturedItems**](DefaultApi.md#getfeatureditems) | **POST** /featured-items | Get featured items
[**getImage**](DefaultApi.md#getimage) | **GET** /images/{imageId} | Get raw image data
[**getInfo**](DefaultApi.md#getinfo) | **GET** /info | Get server info
[**getItem**](DefaultApi.md#getitem) | **GET** /items/{itemId} | Get item details
[**getItemEdit**](DefaultApi.md#getitemedit) | **GET** /items/{itemId}/edit | Get item edit details (owner only)
[**getRentRequest**](DefaultApi.md#getrentrequest) | **GET** /rent-requests/{requestId} | Get a single rent request with messages and offers
[**getRentRequests**](DefaultApi.md#getrentrequests) | **GET** /rent-requests | List rent requests for current user
[**login**](DefaultApi.md#login) | **POST** /auth/login | Login
[**logout**](DefaultApi.md#logout) | **POST** /auth/logout | Logout
[**markRentRequestRead**](DefaultApi.md#markrentrequestread) | **POST** /rent-requests/{requestId}/mark-read | Mark a rent request as read
[**refresh**](DefaultApi.md#refresh) | **POST** /auth/refresh | Refresh tokens
[**searchItems**](DefaultApi.md#searchitems) | **POST** /items/search | Search items
[**seedDatabase**](DefaultApi.md#seeddatabase) | **POST** /seed | Seed the database with demo data
[**sendMessage**](DefaultApi.md#sendmessage) | **POST** /rent-requests/{requestId}/messages | Send a message in a rent request chat
[**submitRentRatings**](DefaultApi.md#submitrentratings) | **POST** /rent-requests/{requestId}/ratings | Rate the other participant and, for borrowers, the item after return
[**updateItem**](DefaultApi.md#updateitem) | **PUT** /items/{itemId} | Update an item
[**uploadItemImage**](DefaultApi.md#uploaditemimage) | **POST** /items/{itemId}/images | Upload an image for an item
[**verify**](DefaultApi.md#verify) | **POST** /auth/verify | Verify access token


# **acceptOffer**
> RentOffer acceptOffer(offerId)

Accept an offer

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final offerId = 56; // int | 

try {
    final result = api_instance.acceptOffer(offerId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->acceptOffer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **offerId** | **int**|  | 

### Return type

[**RentOffer**](RentOffer.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmBorrow**
> RentRequestDetail confirmBorrow(requestId)

Confirm that borrowing happened

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final requestId = 56; // int | 

try {
    final result = api_instance.confirmBorrow(requestId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->confirmBorrow: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestId** | **int**|  | 

### Return type

[**RentRequestDetail**](RentRequestDetail.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmReturn**
> RentRequestDetail confirmReturn(requestId)

Confirm item was returned

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final requestId = 56; // int | 

try {
    final result = api_instance.confirmReturn(requestId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->confirmReturn: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestId** | **int**|  | 

### Return type

[**RentRequestDetail**](RentRequestDetail.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createItem**
> CreateItemResponse createItem(createItemRequest)

Create a new item

Creates a new item listing

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final createItemRequest = CreateItemRequest(); // CreateItemRequest | 

try {
    final result = api_instance.createItem(createItemRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->createItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createItemRequest** | [**CreateItemRequest**](CreateItemRequest.md)|  | 

### Return type

[**CreateItemResponse**](CreateItemResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createOffer**
> RentOffer createOffer(requestId, createOfferRequest)

Make or counter an offer

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final requestId = 56; // int | 
final createOfferRequest = CreateOfferRequest(); // CreateOfferRequest | 

try {
    final result = api_instance.createOffer(requestId, createOfferRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->createOffer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestId** | **int**|  | 
 **createOfferRequest** | [**CreateOfferRequest**](CreateOfferRequest.md)|  | 

### Return type

[**RentOffer**](RentOffer.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRentRequest**
> RentRequestDetail createRentRequest(itemId)

Create or get existing open rent request

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final itemId = 56; // int | 

try {
    final result = api_instance.createRentRequest(itemId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->createRentRequest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **int**|  | 

### Return type

[**RentRequestDetail**](RentRequestDetail.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **declineSeed**
> SeedDatabase200Response declineSeed()

Decline seeding prompt

Records that the user declined the seeding prompt. Sets the seeding timestamp without performing the actual seeding. Returns 400 if seeding is disabled. 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.declineSeed();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->declineSeed: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SeedDatabase200Response**](SeedDatabase200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **editItemImages**
> editItemImages(itemId, editItemImagesRequest)

Edit item images (reorder / delete)

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final itemId = 56; // int | 
final editItemImagesRequest = EditItemImagesRequest(); // EditItemImagesRequest | 

try {
    api_instance.editItemImages(itemId, editItemImagesRequest);
} catch (e) {
    print('Exception when calling DefaultApi->editItemImages: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **int**|  | 
 **editItemImagesRequest** | [**EditItemImagesRequest**](EditItemImagesRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFeaturedItems**
> List<ItemOverview> getFeaturedItems(latLng)

Get featured items

Returns a list of featured items

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final latLng = LatLng(); // LatLng | 

try {
    final result = api_instance.getFeaturedItems(latLng);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getFeaturedItems: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **latLng** | [**LatLng**](LatLng.md)|  | [optional] 

### Return type

[**List<ItemOverview>**](ItemOverview.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getImage**
> String getImage(imageId)

Get raw image data

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final imageId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getImage(imageId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getImage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **imageId** | **String**|  | 

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInfo**
> ServerInfo getInfo()

Get server info

Returns server version, API version, and seeding status

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.getInfo();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getInfo: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ServerInfo**](ServerInfo.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getItem**
> ItemDetail getItem(itemId)

Get item details

Returns full details for a single item

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final itemId = 56; // int | 

try {
    final result = api_instance.getItem(itemId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **int**|  | 

### Return type

[**ItemDetail**](ItemDetail.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getItemEdit**
> ItemEditDetail getItemEdit(itemId)

Get item edit details (owner only)

Returns full item details including location for the item owner

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final itemId = 56; // int | 

try {
    final result = api_instance.getItemEdit(itemId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getItemEdit: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **int**|  | 

### Return type

[**ItemEditDetail**](ItemEditDetail.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRentRequest**
> RentRequestDetail getRentRequest(requestId)

Get a single rent request with messages and offers

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final requestId = 56; // int | 

try {
    final result = api_instance.getRentRequest(requestId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getRentRequest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestId** | **int**|  | 

### Return type

[**RentRequestDetail**](RentRequestDetail.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRentRequests**
> List<RentRequestOverview> getRentRequests()

List rent requests for current user

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();

try {
    final result = api_instance.getRentRequests();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getRentRequests: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<RentRequestOverview>**](RentRequestOverview.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **login**
> LoginResult login(loginRequest)

Login

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final loginRequest = LoginRequest(); // LoginRequest | 

try {
    final result = api_instance.login(loginRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->login: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginRequest** | [**LoginRequest**](LoginRequest.md)|  | 

### Return type

[**LoginResult**](LoginResult.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logout**
> logout()

Logout

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();

try {
    api_instance.logout();
} catch (e) {
    print('Exception when calling DefaultApi->logout: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markRentRequestRead**
> markRentRequestRead(requestId)

Mark a rent request as read

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final requestId = 56; // int | 

try {
    api_instance.markRentRequestRead(requestId);
} catch (e) {
    print('Exception when calling DefaultApi->markRentRequestRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestId** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refresh**
> LoginResult refresh(refreshRequest)

Refresh tokens

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final refreshRequest = RefreshRequest(); // RefreshRequest | 

try {
    final result = api_instance.refresh(refreshRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->refresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshRequest** | [**RefreshRequest**](RefreshRequest.md)|  | 

### Return type

[**LoginResult**](LoginResult.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchItems**
> List<ItemOverview> searchItems(itemSearchRequest)

Search items

Search items with filters

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final itemSearchRequest = ItemSearchRequest(); // ItemSearchRequest | 

try {
    final result = api_instance.searchItems(itemSearchRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->searchItems: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemSearchRequest** | [**ItemSearchRequest**](ItemSearchRequest.md)|  | [optional] 

### Return type

[**List<ItemOverview>**](ItemOverview.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **seedDatabase**
> SeedDatabase200Response seedDatabase()

Seed the database with demo data

Triggers database seeding with demo data from the configured seeding directory. This will DELETE all existing data. Returns 400 if seeding is disabled (no valid seeding data found). **This is a development feature.** 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.seedDatabase();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->seedDatabase: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SeedDatabase200Response**](SeedDatabase200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendMessage**
> Message sendMessage(requestId, sendMessageRequest)

Send a message in a rent request chat

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final requestId = 56; // int | 
final sendMessageRequest = SendMessageRequest(); // SendMessageRequest | 

try {
    final result = api_instance.sendMessage(requestId, sendMessageRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->sendMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestId** | **int**|  | 
 **sendMessageRequest** | [**SendMessageRequest**](SendMessageRequest.md)|  | 

### Return type

[**Message**](Message.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitRentRatings**
> SubmittedRentRatings submitRentRatings(requestId, submitRentRatingsRequest)

Rate the other participant and, for borrowers, the item after return

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final requestId = 56; // int | 
final submitRentRatingsRequest = SubmitRentRatingsRequest(); // SubmitRentRatingsRequest | 

try {
    final result = api_instance.submitRentRatings(requestId, submitRentRatingsRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->submitRentRatings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **requestId** | **int**|  | 
 **submitRentRatingsRequest** | [**SubmitRentRatingsRequest**](SubmitRentRatingsRequest.md)|  | 

### Return type

[**SubmittedRentRatings**](SubmittedRentRatings.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateItem**
> CreateItemResponse updateItem(itemId, updateItemRequest)

Update an item

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final itemId = 56; // int | 
final updateItemRequest = UpdateItemRequest(); // UpdateItemRequest | 

try {
    final result = api_instance.updateItem(itemId, updateItemRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->updateItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **int**|  | 
 **updateItemRequest** | [**UpdateItemRequest**](UpdateItemRequest.md)|  | 

### Return type

[**CreateItemResponse**](CreateItemResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadItemImage**
> UploadItemImageResponse uploadItemImage(itemId, uploadItemImageRequest)

Upload an image for an item

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();
final itemId = 56; // int | 
final uploadItemImageRequest = UploadItemImageRequest(); // UploadItemImageRequest | 

try {
    final result = api_instance.uploadItemImage(itemId, uploadItemImageRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->uploadItemImage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **itemId** | **int**|  | 
 **uploadItemImageRequest** | [**UploadItemImageRequest**](UploadItemImageRequest.md)|  | 

### Return type

[**UploadItemImageResponse**](UploadItemImageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verify**
> User verify()

Verify access token

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();

try {
    final result = api_instance.verify();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->verify: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**User**](User.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

