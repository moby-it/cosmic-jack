# CLAUDE.md for Cosmic Jack

## Build/Run Commands
- Run game: `godot -d project.godot`
- Export project: Use Godot's export feature via the GUI
- Debug mode: Run with `-d` flag

## Code Style Guidelines

### GDScript Conventions
- Use tabs for indentation
- Separate functions with a single blank line
- Place signal declarations before variables
- Use explicit typing for functions: `func example() -> ReturnType:`
- Use @export annotations for inspector variables
- Use @onready for Node references

### Naming Conventions
- Functions/variables: snake_case (e.g., `is_mouse_left`, `available_fruits`)
- Classes: PascalCase (e.g., `Wave`, `Convoy`)
- Signals: snake_case (e.g., `fruit_selected`, `change_scene`)

### Resource Loading
- Use preload() for scenes: `preload("res://path/to/scene.tscn")`
- Class definitions: `class_name ClassName`

### Error Handling
- Report errors with: `push_error("error message")`
- Use null/validity checks: `if not is_instance_valid(node):`
- Implement guard clauses for early returns

### Git commit guidelines
- Never co-author commits made by Claude