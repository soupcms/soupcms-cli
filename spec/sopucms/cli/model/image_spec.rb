require 'spec_helper'

ENV['image_upload'] = 'false'

describe SoupCMS::CLI::Model::Image do

  let (:db) { Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'soupcms-cli-test').database }
  let (:coll) { db.collection('images') }


  it 'should create desktop image entity in images collection' do
    image_file = File.new('spec/soupcms-cli-test/posts/structured-logging/splunk-query.png')

    uploader = class_double('Cloudinary::Uploader').as_stubbed_const
    allow(uploader).to receive(:upload).with(image_file, public_id: 'fccc4aacf0af0993f7d70662e45e76e4').and_return({'version' => '12345','public_id' => 'fccc4aacf0af0993f7d70662e45e76e4','format' => 'png'})

    SoupCMS::CLI::Model::Image.new(image_file).create

    doc = coll.find({'doc_id' => 'posts/structured-logging/splunk-query.png'}).to_a[0]
    expect(doc['desktop']).to eq('v12345/fccc4aacf0af0993f7d70662e45e76e4.png')
    expect(doc['desktopMD5']).to eq('fccc4aacf0af0993f7d70662e45e76e4')

  end


  it 'should create mobile image entity in images collection' do
    image_file = File.new('spec/soupcms-cli-test/posts/structured-logging/splunk-query.mobile.png')

    uploader = class_double('Cloudinary::Uploader').as_stubbed_const
    allow(uploader).to receive(:upload).with(image_file, public_id: 'fd19e0daf8b6d2770c718acb63328de4').and_return({'version' => '12345','public_id' => 'fd19e0daf8b6d2770c718acb63328de4','format' => 'png'})

    SoupCMS::CLI::Model::MobileImage.new(image_file).create

    doc = coll.find({'doc_id' => 'posts/structured-logging/splunk-query.png'}).to_a[0]
    expect(doc['mobile']).to eq('v12345/fd19e0daf8b6d2770c718acb63328de4.png')
    expect(doc['mobileMD5']).to eq('fd19e0daf8b6d2770c718acb63328de4')

  end

  it 'should create tablet image entity in images collection' do
    image_file = File.new('spec/soupcms-cli-test/posts/structured-logging/splunk-query.tablet.png')

    uploader = class_double('Cloudinary::Uploader').as_stubbed_const
    allow(uploader).to receive(:upload).with(image_file, public_id: 'cdfc2281bb0512482b01225776109c6a').and_return({'version' => '12345','public_id' => 'cdfc2281bb0512482b01225776109c6a','format' => 'png'})

    SoupCMS::CLI::Model::TabletImage.new(image_file).create

    doc = coll.find({'doc_id' => 'posts/structured-logging/splunk-query.png'}).to_a[0]
    expect(doc['tablet']).to eq('v12345/cdfc2281bb0512482b01225776109c6a.png')
    expect(doc['tabletMD5']).to eq('cdfc2281bb0512482b01225776109c6a')

  end

  it 'should create image with all image types' do
    image_file = File.new('spec/soupcms-cli-test/posts/structured-logging/splunk-query.png')
    mobile_image_file = File.new('spec/soupcms-cli-test/posts/structured-logging/splunk-query.mobile.png')
    tablet_image_file = File.new('spec/soupcms-cli-test/posts/structured-logging/splunk-query.tablet.png')

    uploader = class_double('Cloudinary::Uploader').as_stubbed_const
    allow(uploader).to receive(:upload).and_return({'version' => '12345','public_id' => 'dummy','format' => 'png'})
    SoupCMS::CLI::Model::Image.new(image_file).create
    SoupCMS::CLI::Model::MobileImage.new(mobile_image_file).create
    SoupCMS::CLI::Model::TabletImage.new(tablet_image_file).create

    doc = coll.find({'doc_id' => 'posts/structured-logging/splunk-query.png'}).to_a[0]
    expect(doc['desktop']).to eq('v12345/fccc4aacf0af0993f7d70662e45e76e4.png')
    expect(doc['desktopMD5']).to eq('fccc4aacf0af0993f7d70662e45e76e4')
    expect(doc['mobile']).to eq('v12345/fd19e0daf8b6d2770c718acb63328de4.png')
    expect(doc['mobileMD5']).to eq('fd19e0daf8b6d2770c718acb63328de4')
    expect(doc['tablet']).to eq('v12345/cdfc2281bb0512482b01225776109c6a.png')
    expect(doc['tabletMD5']).to eq('cdfc2281bb0512482b01225776109c6a')
  end

  it 'should not update or upload image again if already present' do
    doc = {'doc_id' => 'posts/structured-logging/splunk-query.png', 'desktop' => 'v12345/dummy.png', 'desktopMD5' => 'fccc4aacf0af0993f7d70662e45e76e4','version' => 1}
    coll.insert_one(doc)

    image_file = File.new('spec/soupcms-cli-test/posts/structured-logging/splunk-query.png')
    SoupCMS::CLI::Model::Image.new(image_file).create

    doc = coll.find({'doc_id' => 'posts/structured-logging/splunk-query.png'}).to_a[0]
    expect(doc['version']).to eq(1)
  end

end