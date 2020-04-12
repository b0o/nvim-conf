def complete(snip, t, choices, sep):
  if len(t) > 0:
    # allow selection of multiple choices separated by ','
    t = t.split(sep)[-1]
    # narrow choices matching prefix string
    choices = [m[len(t):] for m in choices if m.startswith(t)]
  if len(choices) == 0:
    snip.rv = ""
  # if narrowed down to one choice, return it plainly, prefixed with prefix
  elif len(choices) == 1:
    snip.rv = choices[0]
  else:
    # wrap choices in parens, separate by pipes
    snip.rv = "(" + "|".join(choices) + ")"


def completion(choices, sep=","):
  return lambda snip, t: complete(snip, t, choices, sep)
