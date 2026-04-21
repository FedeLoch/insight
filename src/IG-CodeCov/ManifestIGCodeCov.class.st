"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestIGCodeCov',
	#superclass : 'PackageManifest',
	#category : 'IG-CodeCov-Manifest',
	#package : 'IG-CodeCov',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestIGCodeCov class >> ruleJustSendsSuperRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#IGCoverageMock #initialize #false)) #'2026-04-21T18:17:36.767241+02:00') )
]

{ #category : 'code-critics' }
ManifestIGCodeCov class >> ruleNobodyShouldSendMethodDictV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#IGCodeCoverageProfilerTest #testInstrumentationIsRestoredAfterProfiling #false)) #'2026-04-21T17:54:29.852699+02:00') )
]
