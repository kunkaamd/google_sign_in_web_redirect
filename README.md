# google\_sign\_in\_web\_redirect

Implement Sign Google redirect(working for incognito mode).

## Usage

### Import the package

```dart
import 'package:google_sign_in_web_redirect/google_sign_in_web_redirect.dart';
```

### Integration

First, go through the instructions [here](https://developers.google.com/identity/sign-in/web/sign-in#before_you_begin) to create your Google Sign-In OAuth client ID.

On your `web/index.html` file, add the following `meta` tag, somewhere in the
`head` of the document:

```html
<meta name="google-signin-client_id" content="YOUR_GOOGLE_SIGN_IN_OAUTH_CLIENT_ID.apps.googleusercontent.com">
```

For this client to work correctly, the last step is to configure the **Authorized JavaScript origins**, which _identify the domains from which your application can send API requests._ When in local development, this is normally `localhost` and some port.

You can do this by:

1. Going to the [Credentials page](https://console.developers.google.com/apis/credentials).
2. Clicking "Edit" in the OAuth 2.0 Web application client that you created above.
3. Adding the URIs you want to the **Authorized JavaScript origins**.
3. Adding the redirect URIs **Authorized redirect URIs**.

For local development, may add a `localhost` entry, for example: `http://localhost:7357`

#### Starting flutter in http://localhost:7357

Normally `flutter run` starts in a random port. In the case where you need to deal with authentication like the above, that's not the most appropriate behavior.

You can tell `flutter run` to listen for requests in a specific host and port with the following:

```sh
flutter run -d chrome --web-hostname localhost --web-port 7357
```

### Other APIs

Read the rest of the instructions if you need to add extra APIs (like Google People API).


### Using the plugin
Add the following import to your Dart code:

```dart
void main() {
  GoogleSignWeb.getQueryParameters();///make sure add this line
  setPathUrlStrategy();///this package only support PathUrl
  runApp(const MyApp());
}
```

fix issue "There was no corresponding route" with query params:

```dart
onGenerateRoute: (settings) {
  if (settings.name?.contains("/login") ?? false) {
    return MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    );
  }
  return null;
},
```
[Full list of available scopes](https://developers.google.com/identity/protocols/googlescopes).

You can now use the `GoogleSignWeb ` class to authenticate in your Dart code, e.g.

```dart
  initGoogleSignIn() async {
    if(kIsWeb) {
      GoogleSignWeb.init(
        ///id_token if you only want get user_id
        ///code if you need basic profile, access_token
        responseType: "code",
        scopes: ['email', 'profile'],
      );
      if(GoogleSignWeb.instance?.queryParameters?.idToken != null) {
        final jwt = await GoogleSignWeb.instance!.verifyToken();
        final userId = jwt.sub;
        Navigator.pushNamed(context, '/main',arguments: userId);
      } else if (GoogleSignWeb.instance?.queryParameters?.code != null) {
        ///TODO step 1: send code to Server side to take ID Token & basic profile(name, displayname, picture)
        /// we can't make this api from Client side because you need client_secret.
        /// POST /token HTTP/1.1
        /// Host: oauth2.googleapis.com
        /// Content-Type: application/x-www-form-urlencoded
        ///
        /// code=4/P7q7W91a-oMsCeLvIaQm6bTrgtp7&
        /// client_id=your-client-id&
        /// client_secret=your-client-secret&
        /// redirect_uri=https%3A//oauth2.example.com/code&
        /// grant_type=authorization_code
        /// more details: https://developers.google.com/identity/protocols/oauth2/openid-connect#exchangecode
        ///
        ///TODO step 2: verify token get from response Server side
        ///
        /// GoogleSignWeb.instance.token = "YOUR_ID_TOKEN_RESPONSE_FROM_SERVER";
        /// GoogleSignWeb.instance.verifyToken();

        try {
          final response = await http.post(Uri.parse("https://six-colts-rhyme-116-110-109-131.loca.lt/auth/idToken"),body: {
            "code":  GoogleSignWeb.instance!.queryParameters!.code,
          },headers: {
            "Access-Control_Allow_Origin": "*"
          });
          final responseData = jsonDecode(response.body);
          GoogleSignWeb.instance!.token = responseData['id_token'];
          /// final accessToken = responseData['access_token'];
          final jwt = await GoogleSignWeb.instance!.verifyToken();
          Navigator.pushNamed(context, '/main',arguments: jwt.name);
        } catch (_) {
          print(_.toString());
        }
      }
    }
  }

//on press login;
GoogleSignWeb.instance?.signIn();
```

## Example

Find the example wiring in the [google_sign_in_web_redirect](https://github.com/kunkaamd/google_sign_in_web_redirect/tree/master/example).

**Thank you!**
