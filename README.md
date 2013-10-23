Coma
====

A code generator. 

Takes a model description (as JSON or as an Xcode Core Data model), and applies it to a group of templates, to produce source files.

The primary objective is to produce boilerplate classes and methods to support the model.

In this regard it is similar to [Mogenerator](https://github.com/rentzsch/mogenerator).

However, unlike Mogenerator there is no direct link to CoreData, and the model doesn't have to be described using Xcode.

For example, you can use Coma to generate code to:
- support NSCoding
- store/fetch a model with SQLLite
- implement custom getters & setters which do something extra
- implement one or more unit tests for each attribute or relationship
- pretty much anything else that you might want to do repeatedly to each model class

In many cases this is the sort of code that you could either write generically (using introspection, KVO, etc), or write out long-hand for each class. 

In the generic case, the code will be compact but performance may suffer. Sometimes this won't matter, but occasionally it will, which leaves you with the long-hand option. The long-hand code is likely to be tediously repetitive, and thus boring to write and hard to maintain. Coma gives you the option to generate this code automatically, keeping the performance but having the ability to change the templates and rebuild new code at any time.

## Model

Although Coma supports using an Xcode momd file, what it actually does is convert this file into its own JSON model format, and then apply that to generate the source files. 
If you prefer, you can simply work with the JSON format directly.

## Templates

Coma uses the Mustache template language for its templates.

The JSON file that you give Coma as input includes a section which tells it which template files to expand for each model class; thus you can generate as many files as you need.


