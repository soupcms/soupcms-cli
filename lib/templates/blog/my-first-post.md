---
# blog post attributes in front matter format
tags: [<%= configs[:tags].join(",") %>]
title: <%= configs[:title] %>
publish_datetime: 2014-01-01T00:00:07.0Z            # change date in future for draft article
description: Write post description here...
#slug: change-it-to-define-slug-for-the-post        # default slug is sanitized file name
---

## Markdown documentation

This is [markdown template](http://kramdown.gettalong.org/index.html) and quick reference of the markdown language is available [here](http://kramdown.gettalong.org/quickref.html).

## How to add images in post?

To add images on the post copy images in directory 'public/<%= configs[:name] %>/posts/images/<%= configs[:sanitize_title] %>' and use following sample on how to provide image path.

![Images within post](/assets/<%= configs[:name] %>/posts/images/<%= configs[:sanitize_title] %>/1-post-image.png "images with post")






