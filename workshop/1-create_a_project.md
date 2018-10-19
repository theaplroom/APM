# 1  - Create a project

APM builds on top of [Acre-Desktop](https://github.com/the-carlisle-group/Acre-Desktop) in which the recommended way to structure a project is by containing it in its own namespace. Project code is insulated and should remain agnostic of what else is in the workspace. In simple terms, your project code should avoid referencing items in the root and should make no assumptions about where in the workspace the project space is located.

Make sure you have followed the installation instructions on https://github.com/theaplroom/APM before you get started. Also find a suitable folder for the workshop exercises. I will refer to the path as `X:\workshop\` throughout the document, so just replace that with your own path.

## 1.1 Plain Acre project

Let us start by familiarising ourselves with Acre and create our first project. Launch a Dyalog 17.0 session and run the `]ACRE.CreateProject` command to create a new project called `HelloAcre`, like so:

```
      ]ACRE.CreateProject X:\workshop\helloacre #.HelloAcre 
```

If successful you should see a message saying:

```
Added script "quadVars"
#.HelloAcre
```

An easy way to get an idea of what you have in your workspace is by issuing the command `]map`. Try it now.

```
     ]map
#
·   HelloAcre
·   ·   AcreConfig → #.[Namespace]
·   ·   quadVars
```

You should see a single namespace in the root `#.HelloAcre` that contains a couple of items:
* AcreConfig - A space containing Acre-Desktop specific project properties
* quadVars - A space defining default system variables for the project (eg. ⎕IO, ⎕ML, etc)

Now that we have a project, feel free to define a few items inside the project space `#.HelloAcre`. Note that Acre hooks into the editor's fix event, so to make sure that changes are written to file, you should use the editor. It doesn't matter how you invoke the editor (`)ED #.HelloAcre.foo` or `Shift+Enter` on name, etc.). What doesn't work is direct assignments (`#.HelloAcre.foo←{⍵}`).

Open the project folder and see how every new function, operator or namespace/class/interface script gets written to file with file extensions that describe the type of object.

Try creating a subnamespace: 

`)ED #.HelloAcre.Utils`

Can you see the matching folder in the project folder? If not, why?

Now define a function in the new sub space:

`)ED #.HelloAcre.Utils.Salutation`

```
Salutation←{
    'Dear ',⍵
}
```

Once fixed, can you see the file in the project folder? Explain.

## 1.2 APM project

Now that you have tried Acre, let's repeat the exercise with APM. Create a project called `HelloApm`:

```
      ]APM.CreateProject X:\workshop\helloapm #.HelloApm
```

If successful you should see a message saying:

```
Added script "quadVars"
Opening from X:/workshop/helloapm/
 to #.HelloApm
Please wait - Reading 1 file from X:/workshop/helloapm/APLSource/
Project HelloApm created
Current directory set to X:/workshop/helloapm/
Install packages using ]APM.AddPackage         
```

And viewing the workspace content:
```
     ]map
#
·   HelloApm
·   ·   AcreConfig → #.[Namespace]
·   ·   __apm → #.[Namespace]
·   ·   quadVars

```

As you can see there is one new item in the project space. This is the APM configuration space and contains information related to packages, such as dependencies, but also details about the project that are required if it were to be published as a package in its own right. The `__apm` space maps to the file `package.json` in the project folder. Its content for our new project is:

```
      ⊃⎕NGET'./package.json'
{                                              
  "name": "HelloApm",                          
  "version": "1.0.0"                           
}                                              
```

Apart from that, an APM project behaves in the same way as an Acre project. Any object fixed in the project space gets written to disk. Feel free to experiment to confirm this.