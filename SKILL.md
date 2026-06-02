---
name: gym-social-feed
summary: Build and maintain a small-scale Facebook/Instagram-style social feed for a Flutter gym management app. Use this skill when implementing posts, image upload, feed loading, likes, comments, follows, notifications, and related business rules.
---

# Gym Social Feed Skill

## 1. Project Context

This project is a Flutter mobile app named GymManagement. The app includes a customer-facing home screen that behaves like a small-scale social feed for gym members, trainers, and coaches.

The goal is not to build a full Facebook or Instagram clone. The goal is to implement a clean, maintainable, small-scale social posting feature where users can:

- View workout posts in a feed.
- Create posts with text and optional photos/videos.
- Like and unlike posts.
- Comment on posts.
- Follow trainers or other gym users.
- View user profiles.
- Receive simple notifications for likes, comments, and follows.

The expected UI style is dark, gym-focused, modern, and similar to the current `Gym Social` screen.

## 2. Preferred Technology Stack

Use Flutter for the mobile app.

Recommended backend options:

### Option A: Firebase-first implementation

Prefer Firebase when the user wants fast development and easy demo.

Use:

- Firebase Authentication for login/register.
- Cloud Firestore for users, posts, comments, likes, follows, and notifications.
- Firebase Storage for images and videos.
- Firebase Cloud Messaging for push notifications if needed.
- Riverpod or Provider for state management.
- `cached_network_image` for remote image caching.
- `image_picker` for choosing images.

### Option B: Supabase implementation

Use Supabase when the user wants SQL-style tables and relational data.

Use:

- Supabase Auth.
- PostgreSQL tables.
- Supabase Storage.
- Supabase Realtime.

### Option C: Custom API implementation

Use this only when the user wants a more professional backend.

Use:

- Flutter frontend.
- ASP.NET Core Web API or Node.js/NestJS backend.
- SQL Server, PostgreSQL, or MySQL database.
- JWT authentication.
- Cloudinary, Firebase Storage, Supabase Storage, or S3-compatible object storage.
- SignalR or Socket.IO for realtime updates.

## 3. Recommended Folder Structure for Flutter

Codex must follow the current Flutter project folder structure. Do not create a completely new architecture unless the user explicitly asks.

The current project structure is:

```text
lib/
├── app/
│   ├── database/
│   ├── route/
│   └── theme/
│
├── common/
│   ├── styles/
│   └── widgets/
│
├── controllers/
│
├── data/
│   ├── models/
│   ├── repository/
│   └── services/
│
├── models/
│
├── provider/
│
├── screens/
│   ├── admins/
│   ├── customer_home/
│   ├── customer_login/
│   ├── main_Screen_Customer/
│   ├── login_screen.dart
│   └── signup_screen.dart
│
├── utils/
│
├── widget/
│
├── firebase_options.dart
└── main.dart
```

---

### 3.1. Folder Responsibilities

#### `lib/app/`

This folder is used for application-level configuration.

Use this folder for:

```text
lib/app/
├── database/
├── route/
└── theme/
```

Responsibilities:

- `database/`: local database configuration if needed, such as Hive, SQLite, or local cache.
- `route/`: app navigation, route names, and route management.
- `theme/`: global theme, colors, text styles, dark mode, and light mode configuration.

Codex must not place business logic inside `lib/app/`.

---

#### `lib/common/`

This folder contains shared resources that can be reused across many screens.

Use this folder for:

```text
lib/common/
├── styles/
└── widgets/
```

Responsibilities:

- `styles/`: shared colors, spacing, text styles, and UI constants.
- `widgets/`: reusable widgets used in many parts of the app.

Examples:

```text
lib/common/widgets/custom_button.dart
lib/common/widgets/custom_text_field.dart
lib/common/widgets/loading_widget.dart
lib/common/widgets/error_message.dart
```

For the social feed feature, shared widgets may include:

```text
lib/common/widgets/cached_image_widget.dart
lib/common/widgets/avatar_widget.dart
lib/common/widgets/empty_state_widget.dart
```

---

#### `lib/controllers/`

This folder contains controller classes that handle user actions from screens.

Use controllers when a screen has many actions, such as:

- create post
- update post
- delete post
- like post
- unlike post
- add comment
- delete comment
- pick image
- upload image
- refresh feed

For the social feed feature, Codex may create:

```text
lib/controllers/post_controller.dart
lib/controllers/comment_controller.dart
lib/controllers/profile_controller.dart
```

Controller responsibilities:

- Receive actions from the UI.
- Validate user input.
- Call provider, repository, or service.
- Handle success and error result.
- Keep screens clean and easy to read.

Codex must not put Firebase queries directly inside widgets if the logic can be moved to controller, provider, repository, or service.

---

#### `lib/data/`

This is the main data layer of the app.

Use this folder for:

```text
lib/data/
├── models/
├── repository/
└── services/
```

---

##### `lib/data/models/`

This folder contains data models that map to Firebase, Supabase, REST API, or local database data.

For the social feed feature, Codex should create models here:

```text
lib/data/models/app_user_model.dart
lib/data/models/post_model.dart
lib/data/models/comment_model.dart
lib/data/models/like_model.dart
lib/data/models/notification_model.dart
```

Model classes should include:

- fields
- constructor
- `fromMap`
- `toMap`
- `copyWith` when useful

Example:

```dart
class PostModel {
  final String postId;
  final String userId;
  final String content;
  final List<String> imageUrls;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.userId,
    required this.content,
    required this.imageUrls,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });
}
```

Codex must not place UI code inside model files.

---

##### `lib/data/repository/`

This folder contains repository classes.

Repositories are responsible for communicating with services and preparing data for providers or controllers.

For the social feed feature, Codex may create:

```text
lib/data/repository/post_repository.dart
lib/data/repository/comment_repository.dart
lib/data/repository/user_repository.dart
lib/data/repository/notification_repository.dart
```

Repository responsibilities:

- Call service methods.
- Convert raw data into model objects.
- Hide Firebase, Supabase, or API implementation details from UI.
- Provide clean methods for the app to use.

Example methods:

```dart
Future<void> createPost(PostModel post);
Stream<List<PostModel>> getFeedPosts();
Future<void> likePost(String postId, String userId);
Future<void> unlikePost(String postId, String userId);
Future<void> addComment(String postId, CommentModel comment);
```

Codex must not place UI logic inside repository files.

---

##### `lib/data/services/`

This folder contains direct external service integration.

For Firebase, Codex may create:

```text
lib/data/services/firebase_auth_service.dart
lib/data/services/firestore_post_service.dart
lib/data/services/firestore_comment_service.dart
lib/data/services/firestore_user_service.dart
lib/data/services/firebase_storage_service.dart
lib/data/services/firebase_notification_service.dart
```

Service responsibilities:

- Directly call Firebase Auth.
- Directly call Cloud Firestore.
- Directly call Firebase Storage.
- Directly call Firebase Cloud Messaging if needed.
- Return raw data or model-ready data to repository.

Codex must not place UI logic inside service files.

---

#### `lib/models/`

This folder already exists in the project.

Codex should avoid duplicating models here if `lib/data/models/` is already being used.

Recommended rule:

- Use `lib/data/models/` for new social feed models.
- Use `lib/models/` only if the existing project already stores old app models there.
- Do not create duplicate model classes in both folders.

Do not create both:

```text
lib/models/post_model.dart
lib/data/models/post_model.dart
```

Use only:

```text
lib/data/models/post_model.dart
```

---

#### `lib/provider/`

This folder contains state management classes.

Use this folder for Provider or Riverpod state classes.

For this project, Codex should prefer `Provider` unless the project already uses Riverpod.

For the social feed feature, Codex may create:

```text
lib/provider/post_provider.dart
lib/provider/comment_provider.dart
lib/provider/user_provider.dart
lib/provider/notification_provider.dart
```

Provider responsibilities:

- Store screen state.
- Store list of posts.
- Store loading state.
- Store error message.
- Notify UI when data changes.
- Call repository methods.

Example state fields:

```dart
bool isLoading = false;
String? errorMessage;
List<PostModel> posts = [];
```

Codex must not place heavy UI code inside provider files.

---

#### `lib/screens/`

This folder contains app screens.

Current structure:

```text
lib/screens/
├── admins/
├── customer_home/
├── customer_login/
├── main_Screen_Customer/
├── login_screen.dart
└── signup_screen.dart
```

For the social feed feature, Codex should place customer-facing social screens inside:

```text
lib/screens/customer_home/social_feed/
```

Recommended files:

```text
lib/screens/customer_home/social_feed/feed_screen.dart
lib/screens/customer_home/social_feed/create_post_screen.dart
lib/screens/customer_home/social_feed/post_detail_screen.dart
lib/screens/customer_home/social_feed/comment_screen.dart
lib/screens/customer_home/social_feed/user_profile_screen.dart
lib/screens/customer_home/social_feed/notification_screen.dart
```

Screen responsibilities:

- `feed_screen.dart`: display the list of posts.
- `create_post_screen.dart`: create a new post with text and images.
- `post_detail_screen.dart`: show one post in detail.
- `comment_screen.dart`: show and create comments.
- `user_profile_screen.dart`: show user profile and user posts.
- `notification_screen.dart`: show like, comment, and follow notifications.

If the existing app already has `home_screen.dart` or `customer_home_screen.dart`, Codex should integrate the feed into the existing screen instead of creating an unrelated screen.

---

#### `lib/utils/`

This folder contains helper functions and utility classes.

Use this folder for:

```text
lib/utils/date_time_helper.dart
lib/utils/image_picker_helper.dart
lib/utils/validator.dart
lib/utils/app_constants.dart
```

For the social feed feature, Codex may create:

```text
lib/utils/firestore_collections.dart
lib/utils/post_time_formatter.dart
lib/utils/media_validator.dart
lib/utils/firebase_error_handler.dart
```

Utility responsibilities:

- Format date and time.
- Validate image size and type.
- Convert Firebase errors to user-friendly messages.
- Store constants such as Firestore collection names.

Example:

```dart
class FirestoreCollections {
  static const users = 'users';
  static const posts = 'posts';
  static const comments = 'comments';
  static const likes = 'likes';
  static const notifications = 'notifications';
}
```

---

#### `lib/widget/`

This folder already exists and contains current project widgets.

Current examples:

```text
lib/widget/home_Customer/
├── bottom_nav_bar.dart
├── header_section.dart
├── health_stats_row.dart
├── next_session_card.dart
├── qr_check_in_card.dart
├── quick_actions_section.dart
├── search_box.dart
└── session_carousel.dart

lib/widget/LoginAndSignInWidget/
├── auth_background.dart
├── auth_text_field.dart
├── brand_logo.dart
├── divider_text.dart
├── primary_button.dart
├── social_button.dart
├── status_card.dart
└── step_indicator.dart
```

Codex should continue using this folder for feature-specific UI widgets that belong to existing screens.

For the social feed feature, create:

```text
lib/widget/social_feed/
├── post_card.dart
├── create_post_box.dart
├── post_action_bar.dart
├── comment_item.dart
├── user_avatar.dart
├── image_grid.dart
└── post_skeleton.dart
```

Widget responsibilities:

- `post_card.dart`: UI for one post.
- `create_post_box.dart`: small input card at the top of feed.
- `post_action_bar.dart`: like, comment, and share buttons.
- `comment_item.dart`: UI for one comment.
- `user_avatar.dart`: reusable avatar widget.
- `image_grid.dart`: display one or many post images.
- `post_skeleton.dart`: loading placeholder.

Codex must not place Firebase, Supabase, API, or database logic inside widget files.

---

### 3.2. Recommended Social Feed File Structure

When implementing the social feed feature, Codex should add files using the structure below:

```text
lib/
├── data/
│   ├── models/
│   │   ├── app_user_model.dart
│   │   ├── post_model.dart
│   │   ├── comment_model.dart
│   │   ├── like_model.dart
│   │   └── notification_model.dart
│   │
│   ├── repository/
│   │   ├── post_repository.dart
│   │   ├── comment_repository.dart
│   │   ├── user_repository.dart
│   │   └── notification_repository.dart
│   │
│   └── services/
│       ├── firebase_auth_service.dart
│       ├── firestore_post_service.dart
│       ├── firestore_comment_service.dart
│       ├── firestore_user_service.dart
│       ├── firebase_storage_service.dart
│       └── firebase_notification_service.dart
│
├── provider/
│   ├── post_provider.dart
│   ├── comment_provider.dart
│   ├── user_provider.dart
│   └── notification_provider.dart
│
├── controllers/
│   ├── post_controller.dart
│   └── comment_controller.dart
│
├── screens/
│   └── customer_home/
│       └── social_feed/
│           ├── feed_screen.dart
│           ├── create_post_screen.dart
│           ├── post_detail_screen.dart
│           ├── comment_screen.dart
│           ├── user_profile_screen.dart
│           └── notification_screen.dart
│
├── widget/
│   └── social_feed/
│       ├── post_card.dart
│       ├── create_post_box.dart
│       ├── post_action_bar.dart
│       ├── comment_item.dart
│       ├── user_avatar.dart
│       ├── image_grid.dart
│       └── post_skeleton.dart
│
└── utils/
    ├── firestore_collections.dart
    ├── post_time_formatter.dart
    └── media_validator.dart
```

---

### 3.3. Naming Convention

Codex must follow these naming rules:

- File names use `snake_case`.
- Class names use `PascalCase`.
- Variables and methods use `camelCase`.
- Provider classes end with `Provider`.
- Repository classes end with `Repository`.
- Service classes end with `Service`.
- Model classes end with `Model`.
- Controller classes end with `Controller`.

Examples:

```dart
class PostModel {}
class PostProvider {}
class PostRepository {}
class FirestorePostService {}
class PostController {}
```

---

### 3.4. Architecture Rule

Codex must follow this data flow:

```text
Screen
  -> Widget
  -> Controller / Provider
  -> Repository
  -> Service
  -> Firebase / Supabase / REST API
```

Recommended flow for loading feed:

```text
FeedScreen
  -> PostProvider
  -> PostRepository
  -> FirestorePostService
  -> Cloud Firestore
```

Recommended flow for creating a post:

```text
CreatePostScreen
  -> PostController
  -> PostRepository
  -> FirebaseStorageService
  -> FirestorePostService
  -> Cloud Firestore
```

Recommended flow for comments:

```text
CommentScreen
  -> CommentProvider
  -> CommentRepository
  -> FirestoreCommentService
  -> Cloud Firestore
```

Recommended flow for likes:

```text
PostCard
  -> PostController / PostProvider
  -> PostRepository
  -> FirestorePostService
  -> Cloud Firestore transaction
```

Widgets must not directly call Firebase, Supabase, REST API, or database queries.

---

### 3.5. Firebase Collection Structure

If Firebase is used, Codex should use this Firestore collection structure:

```text
users/
  {userId}
    uid
    fullName
    email
    avatarUrl
    bio
    createdAt
    updatedAt

posts/
  {postId}
    postId
    userId
    userName
    userAvatarUrl
    content
    imageUrls
    videoUrl
    likeCount
    commentCount
    createdAt
    updatedAt
    isDeleted

posts/
  {postId}/comments/
    {commentId}
      commentId
      postId
      userId
      userName
      userAvatarUrl
      content
      createdAt
      updatedAt
      isDeleted

posts/
  {postId}/likes/
    {userId}
      userId
      postId
      createdAt

notifications/
  {notificationId}
    notificationId
    receiverId
    senderId
    type
    postId
    commentId
    message
    isRead
    createdAt
```

---

### 3.6. Important Implementation Rules

Codex must follow these rules:

1. Do not create duplicate folders if an equivalent folder already exists.
2. Do not put all logic inside screens.
3. Do not call Firebase directly from UI widgets.
4. Do not duplicate model classes in both `lib/models/` and `lib/data/models/`.
5. Keep post, comment, like, user, and notification logic separated.
6. Use `ListView.builder` for rendering the feed.
7. Use `cached_network_image` for network images.
8. Use pagination or query limits when loading posts.
9. Use Firestore transaction or batch write when updating `likeCount` and `commentCount`.
10. Use `createdAt` ordering for feed posts.
11. Soft delete posts by setting `isDeleted = true` instead of permanently deleting immediately.
12. Keep the UI consistent with the existing dark gym theme.
13. Reuse existing widgets from `lib/widget/home_Customer/` and `lib/common/widgets/` when possible.
14. New social feed widgets must be placed in `lib/widget/social_feed/`.
15. New social feed screens must be placed in `lib/screens/customer_home/social_feed/`.
## 4. Core Data Models

### User Model

A user should contain:

```dart
class AppUserModel {
  final String id;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final String role; // customer, trainer, admin
  final int followersCount;
  final int followingCount;
  final DateTime createdAt;
}
```

Business rules:

- A user must have a unique id.
- Trainer accounts may be shown with a special badge or role label.
- Never store passwords manually in Firestore/Supabase tables. Authentication provider handles credentials.

### Post Model

A post should contain:

```dart
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final List<String> imageUrls;
  final String? videoUrl;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
}
```

Business rules:

- A post must have either text, at least one image, or a video.
- Empty posts are not allowed.
- Deleted posts should preferably be soft-deleted with `isDeleted = true` instead of being physically deleted immediately.
- Feed should not display posts where `isDeleted = true`.
- Newest posts should appear first.

### Comment Model

A comment should contain:

```dart
class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;
  final bool isDeleted;
}
```

Business rules:

- A comment cannot be empty.
- A deleted comment should not be displayed in normal UI.
- When a comment is created, increment the parent post's `commentCount`.
- When a comment is deleted, decrement the parent post's `commentCount` safely.

### Like Model

For Firebase, use a post subcollection:

```text
posts/{postId}/likes/{userId}
```

For SQL/Supabase, use a table:

```text
likes
  id
  post_id
  user_id
  created_at
```

Business rules:

- A user can like a post only once.
- Like/unlike must update `likeCount` safely.
- Use transaction/batch write if supported.
- The UI must show whether the current user already liked the post.

### Follow Model

For Firebase:

```text
users/{targetUserId}/followers/{currentUserId}
users/{currentUserId}/following/{targetUserId}
```

For SQL/Supabase:

```text
follows
  follower_id
  following_id
  created_at
```

Business rules:

- A user cannot follow themselves.
- A user cannot follow the same account twice.
- Following a trainer may be used to prioritize trainer posts in the feed later.

### Notification Model

A notification should contain:

```dart
class NotificationModel {
  final String id;
  final String receiverId;
  final String actorId;
  final String type; // like, comment, follow
  final String? postId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
}
```

Business rules:

- Do not create a notification when a user likes/comments on their own post.
- Notification messages should be short.
- Mark notifications as read when the user opens the notification screen.

## 5. Firebase Firestore Suggested Schema

Use this schema unless the project already has a better existing schema:

```text
users/{userId}
  displayName
  username
  avatarUrl
  bio
  role
  followersCount
  followingCount
  createdAt

posts/{postId}
  authorId
  authorName
  authorAvatarUrl
  content
  imageUrls
  videoUrl
  likeCount
  commentCount
  createdAt
  updatedAt
  isDeleted

posts/{postId}/likes/{userId}
  userId
  createdAt

posts/{postId}/comments/{commentId}
  postId
  authorId
  authorName
  authorAvatarUrl
  content
  createdAt
  isDeleted

users/{userId}/followers/{followerId}
  followerId
  createdAt

users/{userId}/following/{followingId}
  followingId
  createdAt

notifications/{notificationId}
  receiverId
  actorId
  type
  postId
  message
  isRead
  createdAt
```

## 6. Supabase / SQL Suggested Schema

Use this schema when the user chooses Supabase or a custom API:

```sql
users (
  id uuid primary key,
  display_name text not null,
  username text unique,
  avatar_url text,
  bio text,
  role text not null default 'customer',
  followers_count int not null default 0,
  following_count int not null default 0,
  created_at timestamp not null default now()
);

posts (
  id uuid primary key,
  author_id uuid not null references users(id),
  content text,
  video_url text,
  like_count int not null default 0,
  comment_count int not null default 0,
  is_deleted boolean not null default false,
  created_at timestamp not null default now(),
  updated_at timestamp
);

post_images (
  id uuid primary key,
  post_id uuid not null references posts(id),
  image_url text not null,
  sort_order int not null default 0
);

comments (
  id uuid primary key,
  post_id uuid not null references posts(id),
  author_id uuid not null references users(id),
  content text not null,
  is_deleted boolean not null default false,
  created_at timestamp not null default now()
);

likes (
  post_id uuid not null references posts(id),
  user_id uuid not null references users(id),
  created_at timestamp not null default now(),
  primary key (post_id, user_id)
);

follows (
  follower_id uuid not null references users(id),
  following_id uuid not null references users(id),
  created_at timestamp not null default now(),
  primary key (follower_id, following_id)
);

notifications (
  id uuid primary key,
  receiver_id uuid not null references users(id),
  actor_id uuid not null references users(id),
  type text not null,
  post_id uuid references posts(id),
  message text not null,
  is_read boolean not null default false,
  created_at timestamp not null default now()
);
```

## 7. Feed Loading Logic

The feed screen should:

1. Load newest posts first.
2. Display author avatar, author name, time, text, image/video, like count, comment count.
3. Use pagination or infinite scroll.
4. Cache images.
5. Show loading shimmer or progress indicator.
6. Show an empty state if there are no posts.
7. Support pull-to-refresh.

Firebase example behavior:

- Query `posts` where `isDeleted == false`.
- Order by `createdAt` descending.
- Limit to 10 or 20 posts per page.
- Use the last document as cursor for loading more.

Do not load all posts at once.

## 8. Create Post Logic

When creating a post:

1. Validate content and selected media.
2. If images/videos exist, upload them to storage first.
3. Get public download URLs.
4. Create post document/row with text and media URLs.
5. Return to feed or insert the new post at the top.
6. Show error message if upload or save fails.

Validation rules:

- Text-only post is allowed.
- Image-only post is allowed.
- Video-only post is allowed.
- Completely empty post is not allowed.
- Limit images to a reasonable number, for example 4 or 6.
- Compress images if possible before upload.

## 9. Like / Unlike Logic

When the user taps like:

1. Check if the user already liked the post.
2. If not liked:
   - Create like record.
   - Increment `likeCount`.
   - Create notification for post owner if actor is not owner.
3. If already liked:
   - Delete like record.
   - Decrement `likeCount`, but never below 0.
4. Update UI optimistically, but rollback if request fails.

Use transaction or batch write to avoid wrong counters.

## 10. Comment Logic

When the user sends a comment:

1. Validate content is not empty.
2. Create comment record.
3. Increment post `commentCount`.
4. Create notification for post owner if actor is not owner.
5. Clear comment input.
6. Scroll to the newest comment if appropriate.

When deleting a comment:

1. Only allow author or admin to delete.
2. Soft-delete the comment or remove it.
3. Decrement `commentCount`, but never below 0.

## 11. Follow Logic

When the user taps follow:

1. Prevent self-follow.
2. Check whether current user already follows target user.
3. If not following:
   - Create follower/following records.
   - Increment target `followersCount`.
   - Increment current user `followingCount`.
   - Create follow notification.
4. If already following:
   - Remove follower/following records.
   - Decrement counts safely.

## 12. UI Requirements

The UI should match the current dark gym style.

Recommended style:

- Dark background.
- Rounded cards.
- Trainer posts can show `+ Follow` button.
- Use clear icons for like, comment, share, and notification.
- Use short timestamps such as `2h ago`, `5m ago`, `Yesterday`.
- Avoid overcrowded UI.

Post card should include:

- Author avatar.
- Author display name.
- Timestamp.
- Optional follow button.
- Post content text.
- Post media.
- Like/comment/share row.

## 13. Error Handling Rules

Always handle:

- No internet connection.
- Firebase/Supabase permission errors.
- Upload failure.
- Empty post/comment validation.
- User not logged in.
- Deleted post not found.
- Slow network loading.

Show user-friendly messages in Vietnamese when the surrounding app uses Vietnamese.

Examples:

```text
Không thể tải bài viết. Vui lòng thử lại.
Vui lòng nhập nội dung bài viết hoặc chọn ảnh.
Không thể gửi bình luận. Vui lòng kiểm tra kết nối mạng.
```

## 14. Security Rules / Access Control

Minimum security expectations:

- Only logged-in users can create posts, like, comment, or follow.
- Users can edit/delete only their own posts unless they are admin.
- Users can delete only their own comments unless they are admin.
- Public feed can read non-deleted posts.
- Do not trust client-side counters only. Backend/security rules should prevent invalid writes when possible.

## 15. Performance Rules

- Use pagination for feed and comments.
- Use `cached_network_image` for image URLs.
- Avoid nested scroll views that cause jank.
- Avoid loading all comments directly inside each post card.
- Feed card should only show comment count; open detail screen to load comments.
- Dispose controllers properly.
- Keep widgets small and reusable.

## 16. State Management Rules

If the project already uses Provider, continue using Provider.

If no state management exists yet, prefer Riverpod for new social-feed work.

State should separate:

- Authentication state.
- Feed state.
- Create post state.
- Post detail/comment state.
- Profile/follow state.

Avoid placing all business logic directly inside UI widgets.

## 17. Coding Style Rules

When writing code for this project:

- Follow existing file names and folder naming as much as possible.
- Do not rewrite unrelated screens.
- Do not remove existing UI unless requested.
- Prefer small service classes for backend operations.
- Prefer model classes with `fromMap`, `toMap`, or equivalent serialization methods.
- Use null-safety correctly.
- Add clear comments only where logic is not obvious.
- Keep Vietnamese UI text if the current app uses Vietnamese.
- Keep English identifiers in code.

## 18. Implementation Order

When the user asks to implement this feature, follow this order:

1. Add dependencies.
2. Configure Firebase/Supabase if not configured.
3. Create models.
4. Create services.
5. Create providers/state management.
6. Build reusable widgets.
7. Build feed screen.
8. Build create post screen.
9. Add like/unlike.
10. Add comments screen.
11. Add follow/profile logic.
12. Add notifications if required.
13. Test on emulator.
14. Clean up errors and edge cases.

## 19. Testing Checklist

Before considering the feature done, verify:

- User can create a text-only post.
- User can create an image post.
- Feed loads newest posts first.
- Pull-to-refresh works.
- Infinite scroll works or at least does not load all data at once.
- Like works only once per user.
- Unlike decrements count correctly.
- Comment creation increments comment count.
- Empty comments are blocked.
- Follow button prevents self-follow.
- Images load from cache after first load.
- App does not crash when author avatar is null.
- App handles no-post state.
- App handles network error.

## 20. What Not To Do

Do not:

- Build a full Facebook clone.
- Load all posts at once.
- Store image files directly in Firestore or SQL tables.
- Put all logic inside one screen file.
- Trust client-side like/comment counters without safe update logic.
- Allow duplicate likes from the same user.
- Allow empty posts or comments.
- Break existing login/signup screens.
- Change unrelated project architecture without asking.

## 21. Useful User Prompts This Skill Should Support

Examples of tasks this skill should help with:

- "Tạo màn hình feed bài viết giống Facebook bản nhỏ."
- "Thêm chức năng đăng bài có ảnh bằng Firebase."
- "Viết PostModel, CommentModel và PostService cho Flutter."
- "Làm like/unlike tránh bị like trùng."
- "Tạo comments screen cho bài viết."
- "Tối ưu ListView feed để không lag."
- "Chuyển logic đăng bài ra service riêng."
- "Viết rules nghiệp vụ cho social feed gym app."

## 22. Default Recommendation

Unless the user explicitly chooses another backend, prefer this stack:

```text
Flutter + Firebase Authentication + Cloud Firestore + Firebase Storage + Provider/Riverpod + cached_network_image + image_picker
```

This stack is the best default for a small-scale social feed because it is fast to develop, easy to demo, and does not require maintaining a custom backend server.
