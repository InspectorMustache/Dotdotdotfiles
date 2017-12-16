# set our abbreviations if there are none
# (updates have to be done manually)
if not count $fish_user_abbreviations > /dev/null
    __fish_set_user_abbreviations
end

# set global variables for this machine if they have never been set before
# (updates also have to be done manually
if not set -q fish_default_variables_set
    __fish_set_universal_variables
end

# always set aliases as these are only set by shell instance
# (so prefer abbreviations)
__fish_set_user_aliases

# initialize event handlers
__fish_load_event_handlers

# initialize SSH agent
__fish_initialize_ssh_agent
