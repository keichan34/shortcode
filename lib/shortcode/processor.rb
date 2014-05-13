class Shortcode::Processor

  def process(string, additional_attributes=nil)
    transformer.apply accelerated_parser.parse(string), additional_attributes: additional_attributes
  end

  private

    def parser
      @parser ||= Shortcode::Parser.new
    end

    def transformer
      @transformer ||= Shortcode::Transformer.new
    end

    def accelerator
      @accelerator ||= Parslet::Accelerator
    end

    def accelerated_parser
      @accelerated_parser ||= accelerator.apply parser,
        accelerator.rule((accelerator.str(:x).absent? >> accelerator.any).repeat) { GobbleUp.new(x) }
    end

end
