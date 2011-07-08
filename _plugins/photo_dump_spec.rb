require 'rubygems'

require 'jekyll'
require 'liquid'
require File.join(File.dirname(__FILE__), 'photo_dump')

require 'rspec'

describe Jekyll::GeneratePhotoDump do
end

describe Jekyll::Photo do

  def quietly
    orig_stdout = $stdout
    $stdout = File.new('/dev/null', 'w')
    result = yield
    $stdout = orig_stdout
    result
  end

  let(:config)  { Jekyll.configuration({}) }
  let(:site)    { quietly { Jekyll::Site.new(config) } }
  let(:dir)     { "_photos" }
  let(:name)    { "2011-06-01-bay-to-breakers.jpg" }

  before do
    @photo = Jekyll::Photo.new(site, site.source, dir, name)
  end

  describe "#process (from the name)" do
    specify "the date" do
      @photo.date.should == Time.parse("2011-06-01")
    end

    specify "the slug" do
      @photo.slug.should == "bay-to-breakers"
    end

    specify "the extension" do
      @photo.ext.should == ".jpg"
    end
  end

  describe "#dir" do
    specify "the directory" do
      @photo.dir.should == "/photos"
    end
  end

  describe "#permalink" do
    it "should be underneath the site/photos" do
      @photo.permalink.should == nil
    end
  end

  describe "#template" do
    it "produces a reasonable format" do
      @photo.template.should == "#{@photo.dir}/:year-:month-:day-:title.jpg"
    end
  end

  describe "#url" do
    specify { @photo.url.should == "/photos/2011-06-01-bay-to-breakers.jpg" }
  end

  describe "#id" do
    specify { @photo.id.should == "/photos/2011-06-01-bay-to-breakers.jpg" }
  end

  describe "#render" do
    def do_render(photo)
      photo.render({}, {"site" => {"posts" => []}})
    end

    it "works" do
      do_render(@photo)
      @photo.output.should == "<img src=\"#{@photo.id}\" />\n"
    end
  end

  describe "#destination" do
    specify { @photo.destination("/").should == "/photos/2011-06-01-bay-to-breakers.jpg" }
  end

  describe "#write" do
    let(:expected_path) { File.join("photos", name) }

    after do
      File.delete(expected_path)
    end

    it "puts the junk in the boot" do
      @photo.write(".")
      File.exists?(expected_path).should be_true
      File.read(expected_path).should == File.read( File.join(dir, name) )
    end
  end

  describe "#to_liquid" do
    specify do
      liquid = @photo.to_liquid
      liquid.should_not be_empty
    end
  end

  describe "#inspect" do
    it "is useful" do
      result = @photo.inspect
      result.should match(/breakers/i)
    end
  end

end
