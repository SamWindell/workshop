#!/bin/bash

PLACES_DB=$(fd '^places.sqlite$' $HOME/.mozilla/firefox/ -t f)

generate_paths() {
    local filter="$1"
    # Create temporary copy to avoid database locks
    tmp_db="/tmp/places_temp.sqlite"
    cp "$PLACES_DB" "$tmp_db"

    # Add WHERE clause for filtering if a folder is specified
    local filter_clause=""
    if [ -n "$filter" ]; then
        filter_clause="AND folders.full_path || '/' || b.title LIKE '$filter/%'"
    fi

    sqlite3 "$tmp_db" "
        WITH RECURSIVE
        folders(id, title, parent, full_path) AS (
            SELECT 
                id,
                title,
                parent,
                title as full_path
            FROM moz_bookmarks 
            WHERE parent = 1
            
            UNION ALL
            
            SELECT 
                b.id,
                b.title,
                b.parent,
                folders.full_path || '/' || b.title
            FROM moz_bookmarks b
            JOIN folders ON b.parent = folders.id
        )
        SELECT DISTINCT
            folders.full_path || '/' || b.title
        FROM moz_bookmarks b
        LEFT JOIN moz_places p ON b.fk = p.id
        LEFT JOIN folders ON b.parent = folders.id
        WHERE b.type = 1 
        AND b.title IS NOT NULL 
        AND p.url IS NOT NULL
        $filter_clause
        ORDER BY 1;"

    rm "$tmp_db"
}

get_url() {
    local full_path="$1"
    # Create temporary copy to avoid database locks
    tmp_db="/tmp/places_temp.sqlite"
    cp "$PLACES_DB" "$tmp_db"

    sqlite3 "$tmp_db" "
        WITH RECURSIVE
        folders(id, title, parent, full_path) AS (
            SELECT 
                id,
                title,
                parent,
                title as full_path
            FROM moz_bookmarks 
            WHERE parent = 1
            
            UNION ALL
            
            SELECT 
                b.id,
                b.title,
                b.parent,
                folders.full_path || '/' || b.title
            FROM moz_bookmarks b
            JOIN folders ON b.parent = folders.id
        )
        SELECT p.url
        FROM moz_bookmarks b
        LEFT JOIN moz_places p ON b.fk = p.id
        LEFT JOIN folders ON b.parent = folders.id
        WHERE b.type = 1 
        AND folders.full_path || '/' || b.title = '$full_path'
        AND p.url IS NOT NULL
        LIMIT 1;"

    rm "$tmp_db"
}

case "$1" in
    --list)
        shift
        generate_paths "$1"
        ;;
    --url)
        shift
        get_url "$*"
        ;;
    *)
        echo "Usage:"
        echo "  $0 --list [folder]              # List all bookmarks or filter by folder"
        echo "  $0 --url \"Folder/Sub/Bookmark\"   # Get URL for a bookmark using full path"
        ;;
esac
