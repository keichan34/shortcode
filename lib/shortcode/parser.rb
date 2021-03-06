class Shortcode::Parser < Parslet::Parser

  rule(:block_tag)        { match_any_of Shortcode.configuration.block_tags }
  rule(:self_closing_tag) { match_any_of Shortcode.configuration.self_closing_tags }

  rule(:quotes) { str(Shortcode.configuration.quotes) }

  rule(:space)        { str(' ').repeat(1) }
  rule(:space?)       { space.maybe }
  rule(:newline)      { (str("\r\n") | str("\n")) >> space? }
  rule(:whitespace)   { (space | newline).repeat(1) }
  rule(:whitespace?)  { whitespace.maybe }

  rule(:key)    { match('[a-zA-Z0-9\-_]').repeat(1) }
  rule(:value)  { quotes >> (quotes.absent? >> any).repeat.as(:value) >> quotes }

  rule(:option)   { key.as(:key) >> str('=') >> value }
  rule(:options)  { (str(' ') >> option).repeat(1) }
  rule(:options?) { options.repeat(0, 1) }

  rule(:open)       { str('[') >> block_tag.as(:open) >> options?.as(:options) >> str(']') >> whitespace? }
  rule(:close)      { str('[/') >> block_tag.as(:close) >> str(']') >> whitespace?  }
  rule(:open_close) { str('[') >> self_closing_tag.as(:open_close) >> options?.as(:options) >> str(']') >> whitespace? }

  rule(:text)   { ((close | block | open_close).absent? >> any).repeat(1).as(:text) }
  rule(:block)  { (open >> (block | text | open_close).repeat.as(:inner) >> close) }

  rule(:body) { (block | text | open_close).repeat.as(:body) }
  root(:body)

  private

    def match_any_of(tags)
      return str('') if tags.length < 1
      tags.map{ |tag| str(tag) }.inject do |tag_chain, tag|
        tag_chain.send :|, tag
      end
    end

end
