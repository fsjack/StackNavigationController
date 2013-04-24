#StackNavigationController
stackNavigationController is a navigationController with stack animation and swipe gesture supported.

![Screenshot](https://github.com/fsjack/StackNavigationController/raw/master/screenshot.png)

##Installation

- Copy over the `StackNavigationController` folder to your project folder.
- Import `QuartzCore` Library to your project
- `#import "StackNavigationController"`


##Usage
Example project included (StackNavigationControllerDemo)

###Initialization
`SNBaseNavigationController *navigationController = [SNBaseNavigationController navigationWithRootController:self.viewController navigationTransitionStyle:SNBaseNavigationTransitionStyleStack];`

There's two transitionStyle SNBaseNavigationTransitionStyleDefault and SNBaseNavigationTransitionStyleStack,SNBaseNavigationTransitionStyleDefault act exactly the same with NavigationController.

###How to obtain viewController's navigationController
If you use SNBaseNavigationController as your containerViewController it'd be confuse how to obtain viewController's navigationController since it's no longer UINavigationController.But I have fix this problem so you can get obtain SNbaseNavigationController by using `self.navigationController` and
`self.baseNavigationController` also is fine.


##Notes
### NO TabBar supproted yet
### Automatic Reference Counting (ARC) support
StackNavigationController was made with ARC enabled by default.

## Contact
- [GitHub](http://github.com/fsjack)
- [Twitter](http://twitter.com/iamjackiechueng)
- [LinkedIn](http://www.linkedin.com/profile/view?id=91111533)  
- [Email](mailto:fsjack@gmail.com)  
  
## License

### MIT License

Copyright (c) 2012 Jackie CHEUNG

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.




