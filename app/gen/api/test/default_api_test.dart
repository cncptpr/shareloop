//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:openapi/api.dart';
import 'package:test/test.dart';


/// tests for DefaultApi
void main() {
  // final instance = DefaultApi();

  group('tests for DefaultApi', () {
    // Accept an offer
    //
    //Future<RentOffer> acceptOffer(int offerId) async
    test('test acceptOffer', () async {
      // TODO
    });

    // Confirm that borrowing happened
    //
    //Future<RentRequestDetail> confirmBorrow(int requestId) async
    test('test confirmBorrow', () async {
      // TODO
    });

    // Confirm item was returned
    //
    //Future<RentRequestDetail> confirmReturn(int requestId) async
    test('test confirmReturn', () async {
      // TODO
    });

    // Create a new item
    //
    // Creates a new item listing
    //
    //Future<CreateItemResponse> createItem(CreateItemRequest createItemRequest) async
    test('test createItem', () async {
      // TODO
    });

    // Make or counter an offer
    //
    //Future<RentOffer> createOffer(int requestId, CreateOfferRequest createOfferRequest) async
    test('test createOffer', () async {
      // TODO
    });

    // Create or get existing open rent request
    //
    //Future<RentRequestDetail> createRentRequest(int itemId) async
    test('test createRentRequest', () async {
      // TODO
    });

    // Decline seeding prompt
    //
    // Records that the user declined the seeding prompt. Sets the seeding timestamp without performing the actual seeding. Returns 400 if seeding is disabled. 
    //
    //Future<SeedDatabase200Response> declineSeed() async
    test('test declineSeed', () async {
      // TODO
    });

    // Delete an item
    //
    // Delete an item listing. Only the owner can delete. Fails with 409 if the item has active rent requests.
    //
    //Future deleteItem(int itemId) async
    test('test deleteItem', () async {
      // TODO
    });

    // Remove avatar image
    //
    // Delete the avatar image for the authenticated user's profile
    //
    //Future deleteUserAvatar(int userId) async
    test('test deleteUserAvatar', () async {
      // TODO
    });

    // Edit item images (reorder / delete)
    //
    //Future editItemImages(int itemId, EditItemImagesRequest editItemImagesRequest) async
    test('test editItemImages', () async {
      // TODO
    });

    // Follow a user
    //
    // Follow the specified user
    //
    //Future followUser(int userId) async
    test('test followUser', () async {
      // TODO
    });

    // Get booked date ranges for an item
    //
    //Future<List<DateRange>> getBookedDates(int itemId) async
    test('test getBookedDates', () async {
      // TODO
    });

    // Get featured items
    //
    // Returns a list of featured items
    //
    //Future<List<ItemOverview>> getFeaturedItems({ LatLng latLng }) async
    test('test getFeaturedItems', () async {
      // TODO
    });

    // Get raw image data
    //
    //Future<String> getImage(String imageId) async
    test('test getImage', () async {
      // TODO
    });

    // Get server info
    //
    // Returns server version, API version, and seeding status
    //
    //Future<ServerInfo> getInfo() async
    test('test getInfo', () async {
      // TODO
    });

    // Get item details
    //
    // Returns full details for a single item
    //
    //Future<ItemDetail> getItem(int itemId) async
    test('test getItem', () async {
      // TODO
    });

    // Get item edit details (owner only)
    //
    // Returns full item details including location for the item owner
    //
    //Future<ItemEditDetail> getItemEdit(int itemId) async
    test('test getItemEdit', () async {
      // TODO
    });

    // Get a single rent request with messages and offers
    //
    //Future<RentRequestDetail> getRentRequest(int requestId) async
    test('test getRentRequest', () async {
      // TODO
    });

    // List rent requests for current user
    //
    //Future<List<RentRequestOverview>> getRentRequests() async
    test('test getRentRequests', () async {
      // TODO
    });

    // Get user's items
    //
    // Returns all items belonging to the specified user
    //
    //Future<List<ItemOverview>> getUserItems(int userId) async
    test('test getUserItems', () async {
      // TODO
    });

    // Get user profile
    //
    // Returns public profile information for a user
    //
    //Future<UserProfile> getUserProfile(int userId) async
    test('test getUserProfile', () async {
      // TODO
    });

    // Get user ratings
    //
    // Returns all user ratings received by the specified user
    //
    //Future<List<UserRatingDetail>> getUserRatings(int userId) async
    test('test getUserRatings', () async {
      // TODO
    });

    // Login
    //
    //Future<LoginResult> login(LoginRequest loginRequest) async
    test('test login', () async {
      // TODO
    });

    // Logout
    //
    //Future logout() async
    test('test logout', () async {
      // TODO
    });

    // Mark a rent request as read
    //
    //Future markRentRequestRead(int requestId) async
    test('test markRentRequestRead', () async {
      // TODO
    });

    // Refresh tokens
    //
    //Future<LoginResult> refresh(RefreshRequest refreshRequest) async
    test('test refresh', () async {
      // TODO
    });

    // Register a new user
    //
    //Future<LoginResult> register(RegisterRequest registerRequest) async
    test('test register', () async {
      // TODO
    });

    // Search items
    //
    // Search items with filters
    //
    //Future<List<ItemOverview>> searchItems({ ItemSearchRequest itemSearchRequest }) async
    test('test searchItems', () async {
      // TODO
    });

    // Seed the database with demo data
    //
    // Triggers database seeding with demo data from the configured seeding directory. This will DELETE all existing data. Returns 400 if seeding is disabled (no valid seeding data found). **This is a development feature.** 
    //
    //Future<SeedDatabase200Response> seedDatabase() async
    test('test seedDatabase', () async {
      // TODO
    });

    // Send a message in a rent request chat
    //
    //Future<Message> sendMessage(int requestId, SendMessageRequest sendMessageRequest) async
    test('test sendMessage', () async {
      // TODO
    });

    // Rate the borrowed item after return
    //
    //Future<ItemRating> submitItemRating(int requestId, SubmitItemRatingRequest submitItemRatingRequest) async
    test('test submitItemRating', () async {
      // TODO
    });

    // Rate the other participant after return
    //
    //Future<UserRating> submitUserRating(int requestId, SubmitUserRatingRequest submitUserRatingRequest) async
    test('test submitUserRating', () async {
      // TODO
    });

    // Unfollow a user
    //
    // Unfollow the specified user
    //
    //Future unfollowUser(int userId) async
    test('test unfollowUser', () async {
      // TODO
    });

    // Update an item
    //
    //Future<CreateItemResponse> updateItem(int itemId, UpdateItemRequest updateItemRequest) async
    test('test updateItem', () async {
      // TODO
    });

    // Update own profile
    //
    // Update name and/or bio for the authenticated user's profile
    //
    //Future<UserProfile> updateUserProfile(int userId, UpdateUserProfileRequest updateUserProfileRequest) async
    test('test updateUserProfile', () async {
      // TODO
    });

    // Upload an image for an item
    //
    //Future<UploadItemImageResponse> uploadItemImage(int itemId, UploadItemImageRequest uploadItemImageRequest) async
    test('test uploadItemImage', () async {
      // TODO
    });

    // Upload avatar image
    //
    // Upload a new avatar image for the authenticated user's profile. Replaces any existing avatar.
    //
    //Future<UploadItemImageResponse> uploadUserAvatar(int userId, UploadItemImageRequest uploadItemImageRequest) async
    test('test uploadUserAvatar', () async {
      // TODO
    });

    // Verify access token
    //
    //Future<User> verify() async
    test('test verify', () async {
      // TODO
    });

  });
}
