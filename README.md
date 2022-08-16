# flavours_template

This template will ease how you manage your app flavors(Environments).

## Getting Started

There are 4 components in this template that you should know about:

* 'env_config.json' File
* 'Environment' Class
* 'EnvironmentType' enum
* 'pubspec.yaml' File
  
### 'env_config.jso' File

``` Location: project-root > config > env_config.json ```

The env_config file holds the configurations for each environment you have.  
Following is a sample of the file with 5 different environments:

```json
{
    "environments": [
        {
            "id": 0,
            "base_url": "https://10.55.47.40:1102/api/",
            "version_number": "Dev 2.0.12"
        },
        {
            "id": 1,
            "base_url": "https://localhost:44340/api/",
            "version_number": "Local 1.0.9"
        },
        {
            "id": 2,
            "base_url": "https://localhost:44340/api/",
            "version_number": "Mock 1.0.12"
        }
    ]
}
```

As you can see, the json file has list called 'environments' which holds all different flavors for your app. e.g Dev, Prod, Mock.

You can add as many attributes as you wish, as long as you follow the following rules:

* All items inside the 'environments' list must have identical set of attributes
  ```In other words, if you define 'version_number' in the first item, them you must also add 'version_number' to the rest of the items in the list.```
* All attributes must be also defined insid the 'Environemt' class as explained in the next step.
* All items must have 'id' attribute,and with unique value.

### 'Environment' Class

``` Location: project-root > lib > config > environment > environment.dart ```

Your data from env_config file will be mapped & instantaited inside this singelton class.
This class must be initaited at the start of your application using the static 'init' function like this:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.init();
  //runApp
}
```

If you add any new attribute inside env_config, then you must also add the same attribute inside the Environmet class and define them in the fromMap function:

```dart
factory Environment._fromMap(Map<String, dynamic> map) {
    return Environment._(
      id: map['id'] as int,
      baseUrl: map['base_url'] as String,
      versionNumber: map['version_number'] as String,
    );
}
```

### 'EnvironmentType' enum

``` Location: project-root > lib > config > environment > env_type.dart ```

All environments that are defined inside 'env_config' must be also defined here as well. For example:

Given an 'env_config,json' file like this:

```json
{
    "environments": [
        {
            "id": 0,
            "base_url": "https://10.55.47.40:1102/api/",
            "version_number": "Dev 2.0.12"
        },
        {
            "id": 1,
            "base_url": "https://localhost:44340/api/",
            "version_number": "Local 1.0.9"
        },
        {
            "id": 2,
            "base_url": "https://localhost:44340/api/",
            "version_number": "Mock 1.0.12"
        }
    ]
}
```

Will be defined like this inside 'env_type.dart' file:

```dart
enum EnvironmentType {
  dev(0),
  local(1),
  mock(2);

  const EnvironmentType(this.id);
  final int id;

  factory EnvironmentType.fromId(int id) {
    return values.firstWhere((e) => e.id == id);
  }
}
```

The int vlaue of each type must match the id defined in 'env_config.json'.

The purpose of this enum is to be used for comparison instead of integers.
Here is an eaxmple of how to check what is the current running environment:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.init();
  if (Environment().type == EnvironmentType.dev) {
    print('We are running the dev environment!');
  }
  //runApp
}
```

### 'pubspec.yaml' File

``` Location: project-root > pubspec.yaml ```

Here is where you define the environment that you wish to run 😊.

When you open pubspec.yaml, you will find an attribute called 'env'

```yaml
name: flavours_template
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1
env: 2
```

Here, we put 2 in front of 'env', that means we want to run the environment with id equals to 2. In our case, inside 'env_config', we defined 'Mock' environment with id equals to 2.

When we run the app, we will be running inside the mock invironment.
