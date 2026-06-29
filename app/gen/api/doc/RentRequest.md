# openapi.model.RentRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | 
**itemId** | **int** |  | 
**requester** | [**Person**](Person.md) |  | 
**itemTitle** | **String** |  | 
**ownerName** | **String** |  | 
**ownerId** | **int** |  | 
**latestAcceptedOfferId** | **int** |  | [optional] 
**latestOpenOfferId** | **int** |  | [optional] 
**borrowConfirmedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**returnedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 
**messages** | [**List<Message>**](Message.md) |  | [optional] [default to const []]
**offers** | [**List<RentOffer>**](RentOffer.md) |  | [optional] [default to const []]
**lastRead** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


