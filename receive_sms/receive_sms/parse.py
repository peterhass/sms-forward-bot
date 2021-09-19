from functools import reduce

from smspdu.easy import easy_sms

def merge_partial_messages(messages):
    def group_by_partials(acc, message):
        (singles_acc, partials_acc) = acc

        partial = message["partial"]
        if partial:
            reference = partial["reference"]

            if reference not in partials_acc:
                partials_acc[reference] = {}

            partials_acc[reference][partial["part_number"]] = message
        else:
            singles_acc.append(message)

        return singles_acc, partials_acc

    def merge_partials(group):
        indicies = sorted(group.keys())
        merged_message = None

        for index in indicies:
            current_message = group[index]

            if merged_message:
                merged_message["content"] = merged_message["content"] + current_message["content"]
            else:
                merged_message = current_message
                merged_message["partial"] = "merged"

        return merged_message


    (single_messages, partial_groups) = reduce(group_by_partials, messages.values(), ([], {}))
    merged_messages = map(merge_partials, partial_groups.values())

    return sorted([*single_messages, *merged_messages], key=lambda message: message["date"])


def parse_modem_messages(response):
    parts = response.decode().strip().split("\n")
    meta_info = {}
    messages = {}

    active_index = None
    for line in parts:
        if line.startswith("+CMGL:"):
            _, _, command_values_str = line.strip().partition("+CMGL: ")
            meta_strings = command_values_str.split(",")
            active_index = int(meta_strings[0])
            meta_info[active_index] = meta_strings
        elif active_index is not None:
            messages[active_index] = easy_sms(line.strip())

            active_index = None

    return messages
