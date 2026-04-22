# Android
[Build and release an Android app](https://docs.flutter.dev/deployment/android)
## Generate an upload key and keystore

1. Make a `.dev` directory if you do not already have one.
```bash
mkdir .dev
```
2. Generate keystore with the following command:
```bash
keytool -genkey -v -keystore ./.dev/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
  - Generate and store a secure password with Bitwarden.
  - Input your first and last name.
  - Put `Twin Sun` for organizational unit and organization.
  - Put `Nashville` for City.
  - Put `TN` for State.
  - Put `US` for Country Code.

  *This will create* `upload-keystore.jks` *in the* `.dev` *directory of your project.*

  **!!DO NOT CHECK KEYSTORE INTO SOURCE CONTROL!!** *(but, do add to Bitwarden)*

3. Reference the keystore from the app

  - Create a file in the android subdirectory called `key.properties` and supply the following values:

>storePassword=password-from-previous-step
>
>keyPassword=password-from-previous-step
>
>keyAlias=upload
>
>storeFile=../.dev/upload-keystore.jks