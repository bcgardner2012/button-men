extends Node
class_name SkillComboFinder

# takes array of all of 1 player's dice, and a value on an enemy die
static func find(arr: Array[Die], target: int) -> Array:
	var results: Array = []
	_backtrack(arr, 0, target, [], 0, results)
	return results

static func _backtrack(arr: Array[Die], start: int, target: int, current_subset: Array, current_sum: int, results: Array) -> void:
		# If sum matches and subset size >= 2, store it
		if current_sum == target and current_subset.size() >= 2:
			results.append(current_subset.duplicate()) # store a copy
		
		# Explore further elements
		for i in range(start, arr.size()):
			current_subset.append(arr[i])
			_backtrack(arr, i + 1, target, current_subset, current_sum + arr[i].value, results)
			current_subset.pop_back() # undo choice
