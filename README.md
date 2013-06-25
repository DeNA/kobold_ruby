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

##kobold

Modularized helpers.  No import side-effects.  In principle, the only effect of pulling kobold into your project is that
a few extra modules are added to your namespace.  No putting extra methods on built-in types, no implicit changes
to existing behavior.

This is antithetical to activesupport.  It has useful functionality, but pulling it in makes all sorts of changes
to built-in types.  In general, anything that we find useful in activesupport can be pulled into a helper in kobold,
so that we can use the functionality without all the buffoonery that activesupport imposes upon us.

###HashHelper

Standalone functions that work on hashes.  These functions make sense as functions attached to a hash object, but including
them as standalone functions whose first argument is a hash makes just as much sense.

####project_keys(hash_in, list_of_keys)

Takes a hash and a list of keys.  Creates a new hash with only those keys and returns it.  A block can be 
optionally supplied.  If supplied, the block is called for each key in the list_of_keys and its corresponding value.  
The block returns a bool that tells us whether or not to include the key in the hash.  If the block is not supplied, 
we assume that every key is included in the resulting hash.

####choose_alternative_key(hash_in, keys_with_other_names)

