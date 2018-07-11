node.reverse_merge!(
  compilers: {
    install_doc: false,
  },
)

package 'openjdk-8-jdk'
package 'g++'
package 'fpc-3.0.4'

if node.dig(:compilers, :install_doc)
  package 'manpages-dev'
  package 'glibc-doc'
  package 'openjdk-8-doc'
  package 'gcc-doc'
  package 'cpp-doc'
  package 'libstdc++-7-doc'
  package 'fp-docs-3.0.4'
end
