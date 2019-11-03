def complete(t, choices):
	if t:
		t = t.split(",")[-1]
		choices = [ m[len(t):] for m in choices if m.startswith(t) ]
	if len(choices) == 1:
		return choices[0]
	return "(" + "|".join(choices) + ")"

def completion(choices):
	return lambda t: complete(t, choices)
