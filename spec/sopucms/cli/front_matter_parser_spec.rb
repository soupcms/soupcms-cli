require 'spec_helper'

describe SoupCMS::CLI::FrontMatterParser do

  it 'parse string with front matter YAML' do
    text = <<-textwithfrontmatter
---
layout: post
title: Blogging Like a Hacker
---
## Ohh this is awesome and works

    textwithfrontmatter

    attributes, content = SoupCMS::CLI::FrontMatterParser.new.parse(text)
    expect(attributes['layout']).to eq('post')
    expect(attributes['title']).to eq('Blogging Like a Hacker')
    expect(content).to eq('## Ohh this is awesome and works')

  end

  it 'parse string with front matter YAML' do
    text = <<-textwithfrontmatter
## Ohh this is awesome and works
---
layout: post
title: Blogging Like a Hacker
---
## Ohh this is awesome and works

    textwithfrontmatter

    attributes, content = SoupCMS::CLI::FrontMatterParser.new.parse(text)
    expect(attributes).to eq({})
    expect(content).to eq(text)

  end
end