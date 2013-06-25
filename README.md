#kobold

A collection of 4 helper libraries, with some interdependencies.  These libraries, in summary:

kobold - Some basic ruby helpers for hashes and lists.  Also, a comparison helper for deep-comparing two data structures.
kobold_test - Some test helpers for ruby, including some custom assertions and a helper for comparing HTTP responses.
kobold_sinatra_test - Test helpers for Sinatra applications.  Includes a function that issues an HTTP request and validates the response (by code, payload, response headers, etc.).
kobold_rails_test - Test helpers for Ruby on Rails applications. the HTTP request-and-validate function from kobold_sinatra_test.  Also, activeresource_fake, which can be used to isolate tests from external SOA dependencies, where the interface for communicating with these dependencies is activeresource.

The inter-dependencies are:

kobold_test depends on kobold
kobold has no real dependencies, but its tests depend on kobold_test
kobold_sinatra_test depends on kobold_test and kobold
kobold_rails_test depends on kobold_test and kobold

