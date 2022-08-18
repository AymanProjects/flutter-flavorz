# Flavors with Pure Dart 🍧

This package will ease how you manage your app Flavors(Environments).

## Getting Started 

Make sure you are running on Dart version `2.17.0` or later.

### Add this to your package's pubspec.yaml file

* Add `flavorz` your dependencies.
* Add `build_runner` to your dev_dependencies, since we are going to use it to generate the code.

```yaml
dependencies:
  flavorz: ^1.0.0

dev_dependencies:
  build_runner: ^2.2.0
```

Now in terminal, run `dart pub get` or `flutter pub get` to install the packages.

## How to Use

The are 2 files that require your attention:

* `.flavor.json` File
* `.g.dart` File

None of the above files exist in your project yet.
We will create the `.flavor.json` file manullay.
And the `.g.dart` file will be generated by command.

### Create `.flavor.json` File

The `.flavor.json` file holds the configurations for all of your falvors(environments).
And it must be placed anywhere inside the lib folder.

We have to create a new file under the lib folder and name it like this `name.flavor.json`, the name can be anything. but the extension must be the same.

So, let's create an example file and will name it `env.flavor.json`.
Inisde the json file there must be 2 attributes:

* 'environmentToRun'
* 'environments'

'environmentToRun' is a string value that should hold the name of the flavor(environment) that we wish to run.

'environments' is a list of configuration for each flavor. And the each falvor must have the following attribute:

* `_name`

You can add as many attributes as you want after the `_name`.
And you can add as many flavors as you want in the `environments` list.

#### Notes For The Json File

* You should never remove the '_name' attribute
* It is prefferable to use camelCase format for your attribute names
* Attributes that start with an underscore will be generated as private

Following is a sample of how the file should look like:

```json
{
    "environmentToRun": 0,
    "environments": [
        {
            "_name": "dev",
            "versionNumber": "Dev 1.0.0",
            "camelCaseAttribute": ""
        },
        {
            "_name": "local",
            "versionNumber": "Local 1.0.1",
            "camelCaseAttribute": ""
        }
    ]
}
```

As you can see, the 'environments' list holds all different flavors for your app. e.g Dev, Prod, Mock.

### Run The Builder

In your terminal, run `dart run build_runner build` or `flutter pub run build_runner build`
to generate the environment file.

After running the command, a new file will be generated.
The generated file will have the same name & path of the `.flavor.json` file from previous step.
The extension of the generated file will be `.g.dart`

In the example above, we created a json file with this name: `env.flavor.json`,
That means the generated file's name will be: `env.g.dart`

The generated file will contain the `Environment` class that we can use across our app.

## Start Using The Environment Class

* First, from your main file, you must call the `Environment.init()` function. Or else I'll break your PC with an error :)
* After that, you can access your environment data from anywhere in your application using the factory `Environment()`

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

## NOTES

* You only need to run the build_runner when you have changed the attribute names or the number of attributes inside `.flavor.json` file. In other words, if you changed the structure of the flavor.
* If you just changed the values in the `.flavor.json` file, then there is no need to regenerate
