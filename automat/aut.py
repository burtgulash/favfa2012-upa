#! /usr/bin/env python

def bn(n, p):
	s = ""
	for i in range(p):
		s = str(n & 1) + s
		n >>= 1
	return s

def jk(old, new):
	if old == new == 0:
		return ("0", "-")
	if old == new == 1:
		return ("-", "0")
	if old == 0 and new == 1:
		return ("1", "-")
	if old == 1 and new == 0:
		return ("-", "1")

red = [1, 2, 0, 4, 5, -1]
black = [-1, 5, -1, -1, 1, 0]
y = [0, 1, 2, 2, 1, 0]

def make_table(print_empty_rows, delimiter, end):
	delim_between = ""

	for i in range(4):
		for s in range(8):
			new = s
			res = [bn(i, 2), bn(s, 3)]
			
			# print r"\hline"
			if i == 3 or s >= 6:
				res += ["---"] + 4*["--"]
				if print_empty_rows:
					print delimiter.join(list(delim_between.join(res))),
					print end
				continue
				

			if i == 0:
				new = s
			elif i == 1:
				if red[s] >= 0:
					new = red[s]
			elif i == 2:
				if black[s] >= 0:
					new = black[s]

			j1, k1 = jk((s >> 2) & 1, (new >> 2) & 1) 
			j2, k2 = jk((s >> 1) & 1, (new >> 1) & 1)
			j3, k3 = jk(s & 1, new & 1)

			jks = [j1 + k1, j2 + k2, j3 + k3]

			out = y[s]
			res += [bn(new, 3), bn(out, 2)] + jks

			print delimiter.join(list(delim_between.join(res))),
			print end

if __name__ == "__main__":
	# print r"\begin{tabular}{|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c}"
	make_table(False, " & ", r"\\")
	# print r"\hline"
	# print r"\end{tabular}"
