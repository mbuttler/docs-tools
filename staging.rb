# references
# http://stackoverflow.com/questions/36948807/edit-yaml-frontmatter-in-markdown-file

require 'httparty'
require 'yaml'
require 'redcarpet'
require_relative 'environment.rb'
YAML_FRONT_MATTER_REGEXP = /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m

class ZendeskHc
  include HTTParty
  base_uri STAGING

  def initialize(u, p)
      @auth = {username: u, password: p}
  end

  def sections
    JSON.parse(self.class.get("/sections", :basic_auth => @auth).response.body)["sections"]
  end

  def publish(section_id, article_file)
    file = File.read(article_file)
    if file =~ YAML_FRONT_MATTER_REGEXP
      data, content = YAML.load($1), Regexp.last_match.post_match
      #if we want to delete the article later on, this is how it's done
      #response = self.class.delete("/articles/#{data["id"]}.json", :basic_auth => @auth)
      response = self.class.put("/articles/#{data["id"]}/translations/en-us.json", {:body => {:translation => {:title=>get_title(content), :body=>get_html_body(content)}}}.merge!({basic_auth: @auth}))
    else
      data = {}
      content = file
      response = self.class.post("/sections/#{section_id}/articles.json", {:body => {:article => {:title=>get_title(content), :body=>get_html_body(content), :locale => "en-us"}}}.merge!({basic_auth: @auth}))
      front_matter = {"id" => response["article"]["id"]}.to_yaml.concat("---\n")
      File.write(article_file, front_matter.concat(content))
    end

    response
  end

  private

  def get_title(text)
    text.split("\n").first.tr("#","").strip
  end

  def get_html_body(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(with_toc_data: true), autolink: true, tables: true)
    toc = Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC)
    markdown.render(text.split("\n")[1..-1].join("\n").strip).gsub("{{ TOC }}",toc.render(text.split("\n")[1..-1].join("\n").strip))
    # GitHub::Markup.render('article.md', text.split("\n")[1..-1].join("\n").strip)
  end

end
