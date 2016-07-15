import std.stdio;
import std.typecons;
import std.conv;

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

	void add(Key k,Value v){
		const hash = calcHash(&k);
		const index = hash % buckets.length;
		auto entry = new EntryType(k,v,last);

		if(first is null){
			first = entry;
		}
		if(last !is null){
			last.insertion_next = entry;
		}
		last = entry;

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

	struct Range{
		EntryType current;

		bool empty() const{
			return current is null;
		}

		void popFront(){
			current = current.insertion_next;
		}

		Tuple!(Key,Value) front(){
			return Tuple!(Key,Value)(current.key,current.value);
		}
	}

	auto range(){
		return Range(first);
	}
}

void main()
{
    auto map = new LinkedHashMap!(string,int)();
	map.add("abc",1);
	map.add("bbb",3);

	map.get("abc",4).writeln;

	foreach(const v;map.range){
		v.writeln;
	}
}
