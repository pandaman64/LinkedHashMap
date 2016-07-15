import std.stdio;
import std.typecons;
import std.conv;
import std.range;
import std.algorithm;
import std.traits;

class Entry(Key,Value){
	Key key;
	Value value;
	Entry bucket_next;
	Entry insertion_prev,insertion_next;

	this(Key k,Value v,Entry prev){
		key = k;
		value = v;
		bucket_next = null;
		insertion_prev = prev;
		insertion_next = null;
	}
}

class LinkedHashMap(Key,Value){
	alias EntryType = Entry!(Key,Value);
	EntryType[] buckets;
	EntryType first,last;

	this(){
		buckets = new EntryType[10];
		first = last = null;
	}

	private auto calcHash(in Key* k){
		return typeid(Key).getHash(k);
	}

	private EntryType newEntry(Key k,Value v){
		auto entry = new EntryType(k,v,last);

		if(first is null){
			first = entry;
		}
		if(last !is null){
			last.insertion_next = entry;
		}
		last = entry;

		return entry;
	}

	void add(Key k,Value v){
		const hash = calcHash(&k);
		const index = hash % buckets.length;
		auto entry = newEntry(k,v);

		if(buckets[index] is null){
			buckets[index] = entry;
		}
		else{
			auto e = buckets[index];
			while(e.bucket_next !is null){
				if(e.key == entry.key){
					entry.bucket_next = e.bucket_next;
					e = entry;
					return;
				}
			}
			e.bucket_next = entry;
		}
	}

	Value get(Key k,lazy Value defVal){
		const hash = calcHash(&k);
		const index = hash % buckets.length;

		if(buckets[index] is null){
			return defVal;
		}
		else{
			auto entry = buckets[index];
			while(entry.bucket_next !is null){
				if(entry.key == k){
					return entry.value;
				}
			}
			return defVal;
		}
	}

	Value opIndex(Key k){
		const index = calcHash(&k) % buckets.length;
		if(buckets[index] is null){
			auto entry = newEntry(k,Value());
			buckets[index] = entry;
			return entry.value;
		}
		else{
			auto e = buckets[index];
			while(e.bucket_next !is null){
				if(e.key == k){
					return e.value;
				}
			}
			auto entry = newEntry(k,Value());
			e.bucket_next = entry;
			return entry.value;
		}
	}

	Value opIndexAssign(Value v,Key k){
		const index = calcHash(&k) % buckets.length;
		if(buckets[index] is null){
			auto entry = newEntry(k,v);
			buckets[index] = entry;
			return entry.value;
		}
		else{
			auto e = buckets[index];
			while(e.bucket_next !is null){
				if(e.key == k){
					e.value = v;
					return e.value;
				}
			}
			auto entry = newEntry(k,v);
			e.bucket_next = entry;
			return entry.value;
		}
	}

	struct Range{
		alias ValueType = Tuple!(const(Key),Value);
		
		EntryType first,last;

		bool empty(){
			return first is null || first.insertion_prev == last;
		}

		void popFront(){
			first = first.insertion_next;
		}

		void popBack(){
			last = last.insertion_prev;
		}

		ValueType front(){
			return ValueType(first.key,first.value);
		}

		ValueType back(){
			return ValueType(last.key,last.value);
		}

		Range save(){
			return Range(first,last);
		}
	}

	auto range(){
		return Range(first,last);
	}
}

void main()
{
    auto map = new LinkedHashMap!(string,int)();
	map.add("abc",1);
	map.add("bbb",3);
	map["hoge"] = 6;

	map["abc"].writeln;
	map.get("ccc",4).writeln;

	foreach(const v;map.range){
		v.writeln;
	}

	foreach_reverse(const v;map.range){
		v.writeln;
	}
}
