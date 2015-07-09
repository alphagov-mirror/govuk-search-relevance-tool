class ResultSetPresenter
  include ERB::Util

  attr_reader :finder, :document_noun, :results, :total

  delegate :document_noun,
           :filter_sentence_fragments,
           :keywords,
           :atom_url,
           to: :finder

  def initialize(finder, view_context)
    @finder = finder
    @results = finder.results.documents
    @total = finder.results.total
    @view_context = view_context
  end

  def to_hash
    {
      total: total > 1000 ? "1,000+" : total,
      pluralised_document_noun: document_noun.pluralize(total),
      applied_filters: describe_filters_in_sentence,
      documents: documents,
      any_filters_applied: any_filters_applied?,
      atom_url: atom_url,
      next_and_prev_links: next_and_prev_links,
    }
  end

  def any_filters_applied?
    filter_sentence_fragments.length > 0 || keywords.present?
  end

  def describe_filters_in_sentence
    [
      keywords_description,
      selected_filter_descriptions
    ].compact.join(' ')
  end

  def keywords_description
    if keywords.present?
      "containing <strong>#{html_escape(keywords)}</strong>"
    else
      ""
    end
  end

  def selected_filter_descriptions
    filter_sentence_fragments.flat_map { |fragment|
      fragment_description(fragment)
    }.join(' ')
  end

  def fragment_description(fragment)
    [
      fragment.preposition,
      fragment_values_to_s(fragment.values)
    ]
  end

  def fragment_values_to_s(values)
    values.map { |value|
      "<strong>#{html_escape(value.label)}</strong>"
    }.to_sentence(two_words_connector: ' or ', last_word_connector: ' or ')
  end

  def documents
    results.map do |result|
      SearchResultPresenter.new(result).to_hash
    end
  end

private

  attr_reader :view_context

  def next_and_prev_links
    return unless finder.pagination

    current_page = finder.pagination.current_page
    previous_page = current_page - 1 if current_page > 1
    next_page = current_page + 1 if current_page < finder.pagination.total_pages
    pages = {}

    pages[:previous_page] = build_page_link("Previous page", previous_page) if previous_page
    pages[:next_page] = build_page_link("Next page", next_page) if next_page

    view_context.render('govuk_component/previous_and_next_navigation', pages) if pages
  end

  def build_page_link(page_label, page)
    {
      url: [finder.slug, finder.values.merge({page: page}).to_query].reject(&:blank?).join("?"),
      title: page_label,
      label: "#{page} of #{finder.pagination.total_pages}",
    }
  end
end
