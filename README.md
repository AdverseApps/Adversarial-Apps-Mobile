# Adversarial Apps Mobile App

This is the Mobile App Component for our product.

## Getting Started

There are a few ways to install flutter depending on what you are using.

Thus far, the app has been developed in Visual Studio Code. Here is the Document for that setup specifically:

https://docs.flutter.dev/tools/vs-code

## Running

Most dev builds can be run with:
```
flutter run
```
This will run the app as expected as long as you are in the root directory.

## Deployment

To Deploy to our Mobile App Playground, simply put in this command.
Note: Do Not Run this unless it is working on mobile.
```
make deploy OUTPUT=Adversarial-Apps-Mobile-Playground
```

## Troubleshooting

To determine issues with your flutter setup, run the following:
```
flutter doctor
```
Most likely, your Visual Studio (not VSC) is not configured correctly. Most commonly this is due to a missing package. Simply install the package the doctor perscribes.
Typically for every additional dependency it should auto run, but if not, you can run the following command to compile all dependencies:
```
flutter pub get
```
