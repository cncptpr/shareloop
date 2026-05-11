# openapi.api.DefaultApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to */api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getFeaturedItems**](DefaultApi.md#getfeatureditems) | **GET** /featured-items | Get featured items


# **getFeaturedItems**
> List<FeaturedItem> getFeaturedItems()

Get featured items

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.getFeaturedItems();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getFeaturedItems: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<FeaturedItem>**](FeaturedItem.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

