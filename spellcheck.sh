#!/bin/bash

# Author - Roger Lam, mrlamroger@ucla.edu

# Note: 
# - In hindsight, it would be much better to implement in Python.
# - Hacking together a queue and set with arrays and associative arrays
#+caused many hiccups and is a potential source of bugs.
# - Bash also does not deal well with functions and passing by reference.
# - Ideally, I would have getting all possible duplicate permutations as
#+one method and getting all possible vowel combinations as a second method.
# - To test, run bash generatewords.sh | bash spellcheck.sh | grep "NO SUGGESTIONS" 
# - By default, generatewords.sh and spellcheck.sh use the first 25 words from
#+/usr/share/dict/words in the file word_short
# - Uncomment the DICTIONARY_INPUT variable in both files to use the entire dict


# Known issues:
# - Permutation of vowels may create duplicate outcome due to the nature
#+of the algorithm. May take additional runtime.
# - BASH is not the ideal language to code this problem in. 

# Overview:
# - This loads the word, sanitizes it, and finds all possible permutations
#+according to the classes of spelling mistakes (Case, repeated letters,
#+and incorrect vowels).
# - Sanitization is currently converting all letters to lowercase.
# - We find all permutations by first finding all possible reductions when 
#+deleting duplicate letters.
# - For each reduction, we find all possible permutations when 
#+replacing vowels with another vowel (a, e, i, o, u)

# Runtime analysis:
# - Let m be the length and v be the number of vowels and d be the number of
#+duplicates in the input word
# - Sanitization take O(m) to iterate through all the letters once
# - Reduction of duplicate letters take O(2^d + (m-1)) = O(2^d) since each
#+duplicate creates an additional word to continue searching through.
# - For each of the duplicate words, Replacement of vowels takes O(5^v + m) = 
#+O(5^v) since each vowel creates an addition four words to continue 
#+searching though.
# - Total runtime: O(2^d * 5^v)


# Loading Dictionary:
# - Load words into an associative array (hash table).
# - One time cost of loading words in. 
# - Loading: O(N) where N is the number of words in Dictionary 
# - Searching: Average and amortized O(1), worst case O(N) when all words 
#+are placed in the same bucket.

toLower () {
    echo $(echo $1 | tr '[:upper:]' '[:lower:]')
}

DICTIONARY_INPUT="/home/lamr/twitchinterview/words_short"
#DICTIONARY_INPUT="/usr/share/dict/words"

declare -A DICTIONARY

while read word; do
    word=$(toLower $word)
    DICTIONARY[$word]=1
done < $DICTIONARY_INPUT

#for j in "${!DICTIONARY[@]}"; do
#    echo "$j"
#done

# Could not debug... 
#inDictionary () {
#    x=$1
#    if [[ ${DICTIONARY[$x]} ]]; then
#        echo "0"       
#    else
#        echo "1"
#    fi
#}


while read -p"> " input_word; do
    #echo "You entered $input_word"
    input_word=$(toLower $input_word)
    #echo "Lowercased: $input_word"
    
    found=false

    # If the input is a word in the dictionary, you're done!
    if [[ ${DICTIONARY[$input_word]} ]]; then
        echo "$input_word";
        found=true
    else
        # Else, use DUPLICATE as a queue and enqueue permutations of reduced
        #+words. Use ALL_DUPLICATE as a set which removes duplicate words.
        declare -a DUPLICATE=($input_word)
        declare -A ALL_DUPLICATE
        
        ALL_DUPLICATE=()
        ALL_DUPLICATE[$input_word]=$input_word
        while [ ${#DUPLICATE[@]} -gt 0 ]; do
            for (( i=0; i<${#DUPLICATE}-1; i++ )); do
                if [[ ${DUPLICATE:$i:1} == ${DUPLICATE:$i+1:1} ]]; then
                    twochars=${DUPLICATE:$i:2}
                    #echo $twochars
                    removed_dup=$(echo $DUPLICATE | sed "s/.//$((++i))")
                    #echo $removed_dup
                    ALL_DUPLICATE[$removed_dup]=$removed_dup
                    if [[ ${DICTIONARY[$removed_dup]} ]]; then
                        echo "$removed_dup"
                        found=true
                        break 2
                    else
                        DUPLICATE=( "${DUPLICATE[@]}" $removed_dup)
                        #echo "New size is ${#DUPLICATE[@]}"
                    fi
                fi
            done
            DUPLICATE=(${DUPLICATE[@]:1})
            #echo "Removed size is ${#DUPLICATE[@]}"
        done
        
        #for j in "${!ALL_DUPLICATE[@]}"; do
        #    echo "$j"
        #done

        # If we didn't find the word yet, go through the set of duplicates
        #+and stack words with changed vowels in VOWELS. 
        # Each stack in VOWELS belongs to a particular word in ALL_DUPLICATES.
        # Iterate through the length of the word since we don't need to check 
        #+earlier letters of newly created words.     
        if ! $found; then
            #echo "Found: $found"
            declare -a VOWELS
            for j in "${!ALL_DUPLICATE[@]}"; do
                
                VOWELS=( $j )
                num_letters=${#VOWELS}
                for (( i=0; i<$num_letters; i++ )); do
                    for k in "${VOWELS[@]}"; do
                        if [[ ${k:$i:1} == [aeiou] ]]; then
                            
                            
                            change_a=$(echo $k | sed "s/./a/$((++i))")
                            change_e=$(echo $k | sed "s/./e/$((++i))")
                            change_i=$(echo $k | sed "s/./i/$((++i))")
                            change_o=$(echo $k | sed "s/./o/$((++i))")
                            change_u=$(echo $k | sed "s/./u/$((++i))")

                            #echo $change_a
                            #echo $change_e
                            #echo $change_i
                            #echo $change_o
                            #echo $change_u

                            VOWELS=( "${VOWELS[@]}" $change_a )
                            VOWELS=( "${VOWELS[@]}" $change_e )
                            VOWELS=( "${VOWELS[@]}" $change_i )
                            VOWELS=( "${VOWELS[@]}" $change_o )
                            VOWELS=( "${VOWELS[@]}" $change_u )

                            if [[ ${DICTIONARY[$change_a]} ]]; then
                                echo "$change_a"
                                found=true
                                break 3
                            elif [[ ${DICTIONARY[$change_e]} ]]; then
                                echo "$change_e"
                                found=true
                                break 3
                            elif [[ ${DICTIONARY[$change_i]} ]]; then
                                echo "$change_i"
                                found=true
                                break 3
                            elif [[ ${DICTIONARY[$change_o]} ]]; then
                                echo "$change_o"
                                found=true
                                break 3
                            elif [[ ${DICTIONARY[$change_u]} ]]; then
                                echo "$change_u"
                                found=true
                                break 3
                            fi
                        fi
                    done
                done
                VOWELS=($VOWELS[@]:1})
            done 
        fi      
    fi
    
    if ! $found; then
        echo "NO SUGGESTION"
    fi

done




