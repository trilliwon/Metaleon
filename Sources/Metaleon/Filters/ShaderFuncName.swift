//
//  ShaderFuncName.swift
//  Metaleon
//
//  Created by trilliwon on 10/06/2019.
//  Copyright © 2019 trilliwon. All rights reserved.
//

import Foundation

public struct ShaderFuncName {

    public enum Vertex: String {
        case passThrough         = "vertexPassThrough"
        case twoInputPassThrough = "TwoInputVertexPassThrough"
        case linearNearBy        = "linearNearByVertex"
    }

    public enum Fragment: String {
        case passThrough         = "fragmentPassThrough"
        case lookup              = "fragmentLookup"

        case vignetteNormal      = "vignetteFilter"
        case vignetteSoftLight   = "vignetteSoftLightFilter"
        case vignetteOverlay     = "vignetteOverlayFilter"
        case vignetteMultiply    = "vignetteMultiplyFilter"
        case vignetteColorBurn   = "vignetteColorBurnFilter"

        case bilateralFragment   = "bilateralFragment"
        case fastSmoothSkin      = "fastSmoothSkinFilter"

        case alphaBlend          = "alphaBlendFilter"
        case softLight           = "softLightFragment"

        // MARK: - Transition
        case transition          = "transitionFragment"

        // MARK: - VisualEffect
        case grid49              = "grid49Effect"
        case colorIllusion       = "colorIllusionEffect"
        case rgbSpark            = "rgbSparkEffect"
        case trippy              = "trippyEffect"
        case shake               = "shakeEffect"
        case soul                = "soulEffect"
        case spring              = "springEffect"
        case glitch              = "glitchEffect"
        case trail               = "trailEffect"
        case stepVertical        = "stepVerticalEffect"
        case stepHorizontal      = "stepHorizontalEffect"
        case gridColor           = "gridColorEffect"
        case tile                = "tileEffect"
        case mirror              = "mirrorEffect"
        case vhs                 = "vhsEffect"
        case vhsTape             = "vhsTapeEffect"
        case rgbShiftEdge        = "rgbShiftEdgeEffect"
        case vhsTracking         = "vhsTrackingEffect"
        case vcr                 = "vcrEffect"
        case chromaticVHS        = "chromaticVHSEffect"
        case vhsCamera           = "vhsCameraEffect"
        case oldFilm             = "oldFilmEffect"
    }
}
