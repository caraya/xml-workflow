# Things to research

These are the things I want to look at after finishing mvp.

## Deep Linking using Emphasis

The NYT developed a deep linking library called Emphasis ([code](https://github.com/NYTimes/Emphasis) - [writeup](http://open.blogs.nytimes.com/2011/01/11/emphasis-update-and-source/)) that would allow us to create links to specific areas of our content. 

Downside is that it uses jQuery and I'm not certain I want to go through the pain in the ass process of converting it to plain JS or ES6 (and if it's even possible)

Still, if we use jQuery for something else (video manipulation?) it may be worth exploring both as a sharing tool and as a technology.

One thing it doesn't do is handle mobile well, if at all. How do we make this tool work everywhere? [Pointer Events](http://www.w3.org/TR/pointerevents/)?

## Build Media Queries 

Particularly if we want to use the same XSLT and CSS for mutliple projects we need to be able to tailor the display for different devices and viewports. 

Media Queries are the best solution (or are they?)

## Using XSLT to build navigation

The same way we build the table of content should allow us to build navigation within the pages of a publication using preceeding-sibling and following-sibling logic

## Create a better way to generate filenames

The current way to create filenames doesn't take into account that different `section/@type` elements have different starting values. Can we make it start from 1 for every @type in the document?

## Expand the use cases for this project

The original idea was for text and code-heavy content. Is there a case to be made for a more expressive vocabulary? I'm thinking of additional elements for navigation and content display such as asides and blockquotes