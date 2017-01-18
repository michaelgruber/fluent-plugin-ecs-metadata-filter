module FluentECS
  class Error < StandardError; end
  class IntrospectError < Error; end
  class RequestError < IntrospectError; end
end
