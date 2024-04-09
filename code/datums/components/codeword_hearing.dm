/**
 * Component that allows for highlighting of words or phrases in chat based on regular expressions.
 *
 * Hooks into the parent's COMSIG_MOB_HEAR signal to wrap every regex match in the message
 * between <span class=''></span> tags with the provided span class. This modifies the output that
 * is sent to the parent's chat window.
 *
 * Removal of this component should be done by calling [GetComponents(/datum/component/codeword_hearing)]
 * on the parent and then iterating through all components calling [delete_if_from_source(source)].
 */
/datum/component/codeword_hearing
	dupe_mode = COMPONENT_DUPE_ALLOWED

	/// Regex for matching words or phrases you want highlighted.
	var/regex/replace_regex
	/// The <span class=''></span> to use for highlighting matches. // unit test gets mad if you don't close the span here
	var/span_class
	/// The source of this component. Used to identify the source in delete_if_from_source since this component is COMPONENT_DUPE_ALLOWED.
	var/source

/datum/component/codeword_hearing/Initialize(regex/codeword_regex, highlight_span_class, component_source)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	replace_regex = codeword_regex
	span_class = highlight_span_class
	source = component_source
	return ..()

/datum/component/codeword_hearing/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_HEAR, PROC_REF(handle_hearing))

/datum/component/codeword_hearing/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_HEAR)

/// Callback for COMSIG_MOB_HEAR which highlights syndicate code phrases in chat.
/datum/component/codeword_hearing/proc/handle_hearing(datum/source, list/message_l)
	SIGNAL_HANDLER

	var/mob/living/owner = parent
	if(!istype(owner))
		return

	message_l[1] = replace_regex.Replace(message_l[1], "<span class='[span_class]'>$1</span>")

/// Since a parent can have multiple of these components on them simultaneously, this allows a datum to delete components from a specific source.
/datum/component/codeword_hearing/proc/delete_if_from_source(component_source)
	if(source == component_source)
		qdel(src)
		return TRUE

	return FALSE
