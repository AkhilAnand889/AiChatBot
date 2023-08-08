class ChatPage extends StatefulWidget {
  final String token;

  ChatPage(this.token);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<String> messages = []; // Store the history messages

  @override
  void initState() {
    super.initState();
    fetchHistoryMessages();
  }

  // Function to fetch history messages from the API
  Future<void> fetchHistoryMessages() async {
    final url = 'YOUR_BACKEND_API_URL/history'; // Replace with your backend API endpoint for history messages

    try {
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer ${widget.token}'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          messages = List<String>.from(data['messages']);
        });
      } else {
        print('Error fetching history messages');
      }
    } catch (error) {
      print('Error fetching history messages: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (ctx, index) {
            return ListTile(
              title: Text(messages[index]),
            );
          },
        ),
      ),
      body: Container(
        // Chat screen body
      ),
    );
  }
}




ElevatedButton(
  onPressed: _authenticateUser,
  child: Text('Login'),
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: 16.0),
    minimumSize: Size(double.infinity, 0),
  ),
)


<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="aibot"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        android:enableOnBackInvokedCallback="true"
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>



//////
Scaffold(
  appBar: AppBar(
    actions: [
      IconButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            FadeScaleRoute(builder: (context) => LoginScreen()),
          );
        },
        icon: const Icon(Iconsax.logout),
        color: Theme.of(context).colorScheme.background,
      ),
    ],
    toolbarHeight: 60,
    title: AppBarTitle(),
    backgroundColor: ColorSets.botBackgroundColor,
  ),
  backgroundColor: ColorSets.backgroundColor,
  body: SafeArea(
    child: Column(
      children: [
        Text(
          lastWords,
          style: TextStyle(fontSize: 23.0, color: Colors.white),
        ),
        _buildList(),
        Visibility(
          visible: isLoading,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildInput(),
              _buildSubmit(),
            ],
          ),
        ),
      ],
    ),
  ),
  drawer: Drawer(
    child: Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: ColorSets.backgroundColor,
          ),
          child: FutureBuilder<Map<String, dynamic>>(
            future: fetchUserAttributes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AlertDialog(
                  content: Text('Loading....'),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final userAttributes = snapshot.data ?? {};
                final firstName = userAttributes['given_name'] ?? '';
                final email = userAttributes['email'] ?? '';

                return UserAccountsDrawerHeader(
                  decoration:
                      BoxDecoration(color: ColorSets.backgroundColor),
                  currentAccountPictureSize: Size.square(60),
                  accountName: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            AssetImage('Assets/images/7309681.png'),
                        child: Text(
                          firstName.isNotEmpty ? firstName[0] : 'U',
                          style:
                              TextStyle(fontSize: 25.0, color: Colors.blue),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Text(
                        firstName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 5,
                        ),
                      ),
                    ],
                  ),
                  accountEmail: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text(
                      email,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: getAllMessages(),
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AlertDialog(
                  content: Text('Loading....'),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final message = messages[index];
                    final text = message['message'] as String?;
                    return ListTile(
                      leading: const Icon(Icons.message),
                      title: GestureDetector(
                        child: Text(text ?? 'No text'),
                        onLongPress: () {
                          sendMessageToBackend(text!).then((response) {
                            setState(() {
                              isLoading = false;
                              if (response['response'] is List<dynamic>) {
                                final responseList =
                                    response['response'] as List<dynamic>;
                                final joinedResponse =
                                    responseList.join('\n');
                                if (joinedResponse.isNotEmpty) {
                                  _messages.add(
                                    ChatMessage(
                                      text: joinedResponse,
                                      chatMessageType: ChatMessageType.bot,
                                    ),
                                  );
                                  showDialog(
                                    barrierColor: Colors.black,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Response'),
                                        content: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              joinedResponse,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 8,
                                        backgroundColor: Colors.white,
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 16),
                                      );
                                    },
                                  );
                                }
                              } else if (response['response'] is String) {
                                final responseString =
                                    response['response'] as String;
                                if (responseString.isNotEmpty) {
                                  _messages.add(
                                    ChatMessage(
                                      text: responseString,
                                      chatMessageType: ChatMessageType.bot,
                                    ),
                                  );
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Response'),
                                        content: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              responseString,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 8,
                                        backgroundColor: Colors.white,
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 16),
                                      );
                                    },
                                  );
                                }
                              } else if (response['response']
                                      is List<dynamic> &&
                                  response['response'].isEmpty) {
                                _messages.add(
                                  ChatMessage(
                                    chatMessageType: ChatMessageType.bot,
                                    text: response['message'] as String,
                                  ),
                                );
                              }
                            });
                          });
                        },
                      ),
                      trailing: InkWell(
                        child: const Icon(Icons.delete),
                        onTap: () {
                          final messageId = message['id'] as String?;
                          setState(() {
                            if (messageId != null) {
                              deleteMessage(messageId, index);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 45),
            GestureDetector(
              onTap: deleteAllMessages,
              child: Container(
                width: 160,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 106, 101, 101),
                      Color.fromARGB(255, 0, 0, 0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 74, 145, 183)
                          .withOpacity(0.4),
                      offset: Offset(0, 4),
                      blurRadius: 9,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Delete All',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            letterSpacing: 3.0,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => deleteAllMessages()),
          ],
        ),
      ],
    ),
  ),
);
}


//showdialog


showDialog(
barrierColor: Colors.black,
context: context,
builder: (BuildContext context) {
  return AlertDialog(
    title: Text('Response'),
    content: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          joinedResponse,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
      ],
    ),
    actions: [
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('OK'),
      ),
    ],
    shape: RoundedRectangleBorder(
      borderRadius:
          BorderRadius.circular(12),
    ),
    elevation: 8,
    backgroundColor: Colors.white,
    contentPadding:
        EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16),
  );
},
);





















//
class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _emailErrorText;
  String? _passwordErrorText;
  bool _obscurePassword = true;

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

Future<void> _registerUser() async {
  final email = _emailController.text;
  final password = _passwordController.text;
  final firstname = _firstnameController.text;
  final lastname = _lastnameController.text;
  final urls = ApiConstants.signUpUrl;
  final body = jsonEncode({
    'email': email,
    'password': password,
    'firstName': firstname,
    'lastName': lastname
  });

  try {
    final response = await http.post(Uri.parse(urls), body: body);
    if (response.statusCode == 200) {
      print('User registration successful');
      await storage.write(key: 'email', value: email);
      await storage.write(key: 'firstname', value: firstname);

      SnackbarUtils.showSuccessSnackbar(context, 'User Registration Successfull');
      

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerificationScreen(email)),
      );
    } else {
      SnackbarUtils.showErrorSnackbar(context, 'User Registration Failed');
    }
  } catch (error) {
    print('Error registering user: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error registering user: $error'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}


  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 32.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          errorText: _emailErrorText,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        onChanged: (value) {
                          setState(() {
                            _emailErrorText = _validateEmail(value);
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          errorText: _passwordErrorText,
                          suffixIcon: GestureDetector(
                            onTap: _togglePasswordVisibility,
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        onChanged: (value) {
                          setState(() {
                            _passwordErrorText = _validatePassword(value);
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _firstnameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _lastnameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _registerUser();
                          }
                        },
                        child: Container(
                          width: 240,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 54, 220, 148),
                                Color.fromARGB(255, 91, 229, 107),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomCenter,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 161, 183, 74)
                                    .withOpacity(0.5),
                                offset: Offset(0, 4),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: 6.0,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
