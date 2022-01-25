
#!/bin/bash
# exit if this script errors
set -e

#exec sudo --preserve-env --set-home -u ${USER} -g ${USER} $@
echo Running: $@
exec $@