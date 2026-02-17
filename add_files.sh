#!/bin/bash

# Generate UUIDs for each file
UUID1=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
UUID2=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
UUID3=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
UUID4=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
UUID5=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
UUID6=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
UUID7=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
UUID8=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
UUID9=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')
UUID10=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-24 | tr '[:lower:]' '[:upper:]')

PBXPROJ="Souqira.xcodeproj/project.pbxproj"

# Backup
cp "$PBXPROJ" "$PBXPROJ.backup"

# Add PBXBuildFile entries (after first PBXBuildFile section)
sed -i '' "/\/\* Begin PBXBuildFile section \*\//a\\
		$UUID1 /* Message.swift in Sources */ = {isa = PBXBuildFile; fileRef = $UUID2 /* Message.swift */; };\\
		$UUID3 /* MessagesViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = $UUID4 /* MessagesViewModel.swift */; };\\
		$UUID5 /* ConversationsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $UUID6 /* ConversationsView.swift */; };\\
		$UUID7 /* ChatView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $UUID8 /* ChatView.swift */; };\\
		$UUID9 /* MessageComposerView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $UUID10 /* MessageComposerView.swift */; };
" "$PBXPROJ"

# Add PBXFileReference entries
sed -i '' "/\/\* Begin PBXFileReference section \*\//a\\
		$UUID2 /* Message.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Message.swift; sourceTree = \"<group>\"; };\\
		$UUID4 /* MessagesViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MessagesViewModel.swift; sourceTree = \"<group>\"; };\\
		$UUID6 /* ConversationsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ConversationsView.swift; sourceTree = \"<group>\"; };\\
		$UUID8 /* ChatView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ChatView.swift; sourceTree = \"<group>\"; };\\
		$UUID10 /* MessageComposerView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MessageComposerView.swift; sourceTree = \"<group>\"; };
" "$PBXPROJ"

# Add to Models group (find BusinessListing.swift and add after it)
sed -i '' "/BusinessListing.swift/a\\
				$UUID2 /* Message.swift */,
" "$PBXPROJ"

# Add to ViewModels group (find ListingsViewModel.swift and add after it)
sed -i '' "/ListingsViewModel.swift/a\\
				$UUID4 /* MessagesViewModel.swift */,
" "$PBXPROJ"

# Add to Views group (find HomeView.swift and add after it)
sed -i '' "/HomeView.swift/a\\
				$UUID6 /* ConversationsView.swift */,\\
				$UUID8 /* ChatView.swift */,\\
				$UUID10 /* MessageComposerView.swift */,
" "$PBXPROJ"

# Add to PBXSourcesBuildPhase
sed -i '' "/\/\* BusinessListing.swift in Sources \*\//a\\
				$UUID1 /* Message.swift in Sources */,\\
				$UUID3 /* MessagesViewModel.swift in Sources */,\\
				$UUID5 /* ConversationsView.swift in Sources */,\\
				$UUID7 /* ChatView.swift in Sources */,\\
				$UUID9 /* MessageComposerView.swift in Sources */,
" "$PBXPROJ"

echo "✅ Files added to Xcode project!"
echo "UUIDs generated:"
echo "  Message.swift: $UUID1, $UUID2"
echo "  MessagesViewModel.swift: $UUID3, $UUID4"
echo "  ConversationsView.swift: $UUID5, $UUID6"
echo "  ChatView.swift: $UUID7, $UUID8"
echo "  MessageComposerView.swift: $UUID9, $UUID10"
