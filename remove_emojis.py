#!/usr/bin/env python3
"""
Recursive emoji removal script
Traverses all files from root directory and removes emojis using the emoji module
"""

import os
import sys
from pathlib import Path
import emoji
import argparse
from typing import List, Set

# File extensions to process
TEXT_EXTENSIONS = {
    '.py', '.md', '.txt', '.json', '.yaml', '.yml', 
    '.js', '.ts', '.html', '.css', '.sql', '.sh', 
    '.bat', '.ps1', '.env', '.gitignore', '.dockerfile'
}

# Directories to skip
SKIP_DIRECTORIES = {
    '__pycache__', '.git', '.venv', 'venv', 'node_modules', 
    '.cache', '.pytest_cache', '.mypy_cache', 'dist', 
    'build', '.tox', 'htmlcov'
}

# Binary file extensions to skip
BINARY_EXTENSIONS = {
    '.zip', '.tar', '.gz', '.rar', '.7z', '.exe', '.dll',
    '.so', '.dylib', '.bin', '.dat', '.db', '.sqlite',
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.ico',
    '.mp3', '.mp4', '.avi', '.mov', '.wav', '.pdf',
    '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx'
}

class EmojiRemover:
    def __init__(self, root_path: str, dry_run: bool = False):
        self.root_path = Path(root_path)
        self.dry_run = dry_run
        self.files_processed = 0
        self.files_modified = 0
        self.emojis_removed = 0
        self.errors = []

    def should_process_file(self, file_path: Path) -> bool:
        """Check if file should be processed"""
        # Skip if in excluded directory
        for part in file_path.parts:
            if part in SKIP_DIRECTORIES:
                return False
        
        # Skip binary files
        if file_path.suffix.lower() in BINARY_EXTENSIONS:
            return False
        
        # Process text files or files without extension
        return file_path.suffix.lower() in TEXT_EXTENSIONS or file_path.suffix == ''

    def remove_emojis_from_text(self, text: str) -> tuple[str, int]:
        """Remove emojis from text and return cleaned text with count of removed emojis"""
        # Count emojis before removal
        emoji_count = len([char for char in text if emoji.is_emoji(char)])
        
        # Remove emojis
        cleaned_text = emoji.replace_emoji(text, replace='')
        
        return cleaned_text, emoji_count

    def process_file(self, file_path: Path) -> None:
        """Process a single file to remove emojis"""
        try:
            # Read file content
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    original_content = f.read()
            except UnicodeDecodeError:
                # Try with different encoding
                with open(file_path, 'r', encoding='latin-1') as f:
                    original_content = f.read()
            
            # Remove emojis
            cleaned_content, emoji_count = self.remove_emojis_from_text(original_content)
            
            self.files_processed += 1
            
            if emoji_count > 0:
                self.emojis_removed += emoji_count
                
                if not self.dry_run:
                    # Write cleaned content back
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(cleaned_content)
                    self.files_modified += 1
                    print(f"Modified: {file_path} (removed {emoji_count} emojis)")
                else:
                    print(f"Would modify: {file_path} (would remove {emoji_count} emojis)")
            
        except Exception as e:
            error_msg = f"Error processing {file_path}: {str(e)}"
            self.errors.append(error_msg)
            print(f"ERROR: {error_msg}")

    def traverse_and_clean(self) -> None:
        """Recursively traverse directory and clean files"""
        print(f"Starting emoji removal from: {self.root_path}")
        print(f"Dry run mode: {self.dry_run}")
        print("-" * 60)
        
        for root, dirs, files in os.walk(self.root_path):
            # Skip excluded directories
            dirs[:] = [d for d in dirs if d not in SKIP_DIRECTORIES]
            
            for file in files:
                file_path = Path(root) / file
                
                if self.should_process_file(file_path):
                    self.process_file(file_path)

    def print_summary(self) -> None:
        """Print processing summary"""
        print("-" * 60)
        print("EMOJI REMOVAL SUMMARY")
        print("-" * 60)
        print(f"Files processed: {self.files_processed}")
        print(f"Files modified: {self.files_modified}")
        print(f"Total emojis removed: {self.emojis_removed}")
        
        if self.errors:
            print(f"Errors encountered: {len(self.errors)}")
            for error in self.errors:
                print(f"  - {error}")
        
        if self.dry_run:
            print("\nDRY RUN MODE - No files were actually modified")
            print("Run without --dry-run flag to apply changes")

def main():
    parser = argparse.ArgumentParser(description="Recursively remove emojis from all text files")
    parser.add_argument("--root", "-r", default=".", 
                       help="Root directory to start from (default: current directory)")
    parser.add_argument("--dry-run", "-d", action="store_true",
                       help="Show what would be changed without modifying files")
    parser.add_argument("--extensions", "-e", nargs="+", 
                       help="Additional file extensions to process (e.g., .log .cfg)")
    
    args = parser.parse_args()
    
    # Add custom extensions if provided
    if args.extensions:
        TEXT_EXTENSIONS.update(args.extensions)
    
    # Validate root path
    root_path = Path(args.root).resolve()
    if not root_path.exists():
        print(f"ERROR: Root path does not exist: {root_path}")
        sys.exit(1)
    
    if not root_path.is_dir():
        print(f"ERROR: Root path is not a directory: {root_path}")
        sys.exit(1)
    
    # Create emoji remover and process
    remover = EmojiRemover(str(root_path), args.dry_run)
    
    try:
        remover.traverse_and_clean()
        remover.print_summary()
        
        if remover.errors:
            sys.exit(1)
            
    except KeyboardInterrupt:
        print("\nOperation cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"FATAL ERROR: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()