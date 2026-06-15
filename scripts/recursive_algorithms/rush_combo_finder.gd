extends Node
class_name RushComboFinder

# takes all of 1 player's dice, and a value on 1 of the other's
static func find(arr: Array[Die], target: int) -> Array:
	var results: Array[Die] = []
	backtrack(arr, 0, target, [], 0, results)
	return results

static func backtrack(arr: Array[Die], start: int, target: int, current_subset: Array[Die], current_sum: int, results: Array) -> void:
		# If sum matches and subset size == 2, store it
		if current_sum == target and current_subset.size() == 2:
			results.append(current_subset.duplicate()) # store a copy
			return # No need to go deeper since we only want pairs
		
		# Stop exploring if we already have 2 elements
		if current_subset.size() >= 2:
			return
		
		# Explore further elements
		for i in range(start, arr.size()):
			current_subset.append(arr[i])
			backtrack(arr, i + 1, target, current_subset, current_sum + arr[i].value, results)
			current_subset.pop_back() # undo choice
