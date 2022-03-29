{%- include "structs.wgsl" -%}

struct Indices {
	data: array<i32>,
};

struct Chunk {
	data: array<{{ chunk_type }}>,
};

@group(0) @binding(0)
var<storage, read> input_0: Chunk; // data

@group(0) @binding(1)
var<storage, read> input_1: Indices; // indices

@group(0) @binding(2)
var<storage, write> output_0: Chunk;

@stage(compute) @workgroup_size({{ workgroup_size_x }}, {{ workgroup_size_y }})
fn main(@builtin(global_invocation_id) global_id: vec3<u32>) {
	let index_index = global_id.x; // Index of the index in the indices array that we are currently processing
	let chunk_index = global_id.y; // Chunk of elements that we are copying for this index (chunk size determined dynamically)
	let index_stride = {{ i_chunks[0][0] / chunk_size }}u;

	// Negative indexing is apparently allowed; see https://github.com/onnx/onnx/blob/main/docs/Operators.md#inputs-38
	var index = input_1.data[index_index];
	if(index < 0) {
		index = {{ i_shape[0][0] }} + index;
	}

	output_0.data[(index_index * index_stride) + chunk_index] = input_0.data[(index * i32(index_stride)) + i32(chunk_index)];
}