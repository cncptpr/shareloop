# openapi.api.DefaultApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getFeaturedItems**](DefaultApi.md#getfeatureditems) | **POST** /featured-items | Get featured items


# **getFeaturedItems**
> List<FeaturedItem> getFeaturedItems(latLng)

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

[**List<FeaturedItem>**](FeaturedItem.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

