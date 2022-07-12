#!/usr/bin/env python3
# encoding: utf-8

import matplotlib.ticker as tck
from matplotlib import gridspec as gs
import numpy as np
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import os
import os.path as osp

from gridspeccer import core
from gridspeccer.core import log
from gridspeccer import aux


def get_gridspec():
    """
        Return dict: plot -> gridspec
    """

    gs_main = gs.GridSpec(1, 1,
                          left=0.05, right=0.97, top=0.95, bottom=0.08)

    gs_schematics = gs.GridSpecFromSubplotSpec(2, 1, gs_main[0, 0],
                                               height_ratios=[1.5, 2.0],
                                               hspace=0.2)
    gs_tikz = gs.GridSpecFromSubplotSpec(1, 2, gs_schematics[1, 0],
                                         width_ratios=[2, 1])
    gs_lowerRow = gs.GridSpecFromSubplotSpec(1, 2, gs_schematics[0, 0],
                                             wspace=0.35,
                                             width_ratios=[1.5, 1])
    gs_membranes = gs.GridSpecFromSubplotSpec(2, 1, gs_lowerRow[0, 1],
                                              hspace=0.2)

    return {
        # ### schematics
        "arch": gs_tikz[0, 0],

        "coding": gs_tikz[0, 1],

        "psp_shapes": gs_lowerRow[0, 0],

        "membrane_schematic_0": gs_membranes[0, 0],
        "membrane_schematic_1": gs_membranes[1, 0],
    }


def adjust_axes(axes):
    """
        Settings for all plots.
    """
    for ax in axes.values():
        core.hide_axis(ax)

    for k in [
        "arch",
    ]:
        axes[k].set_frame_on(False)


def plot_labels(axes):
    core.plot_labels(axes,
                     labels_to_plot=[
                         "psp_shapes",
                         "membrane_schematic_0",
                         "arch",
                         "coding",
                     ],
                     label_ypos={
                         "arch": 0.87,
                         "coding": 0.87,
                         "psp_shapes": 0.95,
                     },
                     label_xpos={
                     },
                     )


def get_fig_kwargs():
    width = 7.12
    alpha = 10. / 12. / 1.4 / 0.8
    return {"figsize": (width, alpha * width)}


###############################
# Plot functions for subplots #
###############################
#
# naming scheme: plot_<key>(ax)
#
# ax is the Axes to plot into
#
plotEvery = 1
xlim = (0, 100)

name_of_vleak = "$E_\ell$"
name_of_vth = "$\\vartheta$"
exampleClass = 1


def plot_arch(ax):
    # done with tex
    return


def plot_coding(ax):
    # make the axis
    core.show_axis(ax)
    ax.spines['top'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.set_xlabel("time [a.u.]")
    ax.xaxis.set_label_coords(.5, -0.05)
    ax.set_ylabel("neuron id")
    ax.yaxis.set_ticks_position('none')
    ax.xaxis.set_ticks_position('none')
    ax.set_xticks([])
    ax.set_yticks([])

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)

    # #################### draw arrow instead of y axis to have arrow there
    # get width and height of axes object to compute
    # matching arrowhead length and width
    # fig = plt.gcf()
    # dps = fig.dpi_scale_trans.inverted()

    # bbox = ax.get_window_extent()  # .transformed(dps)
    # width, height = bbox.width, bbox.height

    xmin, xmax = ax.get_xlim()
    ymin, ymax = ax.get_ylim()

    # manual arrowhead width and length
    hw = 1. / 20. * (ymax - ymin)
    hl = 1. / 20. * (xmax - xmin)
    lw = 0.5  # axis line width
    ohg = 0.3  # arrow overhang

    # compute matching arrowhead length and width
    # yhw = hw / (ymax - ymin) * (xmax - xmin) * height / width
    # yhl = hl / (xmax - xmin) * (ymax - ymin) * width / height

    ax.arrow(xmin, ymin, xmax - xmin, 0, fc='k', ec='k', lw=lw,
             head_width=hw, head_length=hl, overhang=ohg,
             length_includes_head=True, clip_on=False)
    return


def plot_frame(ax):
    extent_left = 0.05
    extent_right = 0.0
    extent_top = -0.010
    extent_bottom = 0.26
    fancybox = mpatches.Rectangle(
        (-extent_left, -extent_bottom),
        1 + extent_left + extent_right, 1 + extent_bottom + extent_top,
        facecolor="black", fill=True, alpha=0.07,  # zorder=zorder,
        transform=ax.transAxes)
    plt.gcf().patches.append(fancybox)


def plot_frame_bss1(ax):
    plot_frame(ax)


def plot_frame_bss2(ax):
    plot_frame(ax)


def membrane_schematic(ax, should_spike, xAnnotated=False, yAnnotated=False):
    # make the axis
    core.show_axis(ax)
    core.make_spines(ax)

    ylim = (-0.2, 1.2)

    xvals = np.linspace(0., 100., 200)
    c_m = 0.2
    t_s = 10.
    t_m = t_s
    w = 0.032
    t_i1 = 20.
    V_th = 1.

    def theta(x):
        return x > 0

    if should_spike:
        t_i2 = 30.
        t_spike = 35.

        def V(t, before_spike):
            return w / c_m * (
                theta(t - t_i1) * np.exp(-(t - t_i1) / t_m) * (t - t_i1) +
                theta(t - t_i2) * np.exp(-(t - t_i2) / t_m) * (t - t_i2)
            ) * ((t < t_spike) * before_spike + (t > t_spike) * (1 - before_spike))

        ax.plot(xvals, V(xvals, True), color='black')
        ax.plot(xvals[xvals > t_spike], V(xvals[xvals > t_spike], False), color='black', linestyle="dotted")
    else:
        t_i2 = 35.

        def V(t):
            return w / c_m * (
                theta(t - t_i1) * np.exp(-(t - t_i1) / t_m) * (t - t_i1) +
                theta(t - t_i2) * np.exp(-(t - t_i2) / t_m) * (t - t_i2)
            )

        ax.plot(xvals, V(xvals), color='black')

    ax.axhline(V_th, linewidth=1, linestyle='dashed', color='black', alpha=0.6)

    input_arrow_height = 0.17
    arrow_head_width = 2.47
    arrow_head_length = 0.04
    for spk in [t_i1, t_i2]:
        ax.arrow(spk, ylim[0], 0, input_arrow_height,
                 color="black",
                 head_width=arrow_head_width,
                 head_length=arrow_head_length,
                 length_includes_head=True,
                 zorder=-1)

    # output spike
    if should_spike:
        t_out = 34.5
        ax.arrow(t_out, ylim[1], 0, -input_arrow_height,
                 color="black",
                 head_width=arrow_head_width,
                 head_length=arrow_head_length,
                 length_includes_head=True,
                 zorder=-1)

    ax.set_yticklabels([])
    if yAnnotated:
        ax.set_ylabel("membrane voltage")
        ax.yaxis.set_label_coords(-0.2, 1.05)

    ax.set_yticks([V_th, 0])
    ax.set_yticklabels([name_of_vth, name_of_vleak])
    ax.set_ylim(ylim)

    if xAnnotated:
        ax.set_xlabel("time [a. u.]")
        ax.xaxis.set_label_coords(.5, -0.15)
    ax.set_xticks([])


def plot_membrane_schematic_0(ax):
    membrane_schematic(ax, False, xAnnotated=False, yAnnotated=False)


def plot_membrane_schematic_1(ax):
    membrane_schematic(ax, True, xAnnotated=True, yAnnotated=True)


def plot_name(ax, name):
    core.show_axis(ax)
    ax.spines['top'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    ax.spines['right'].set_visible(False)

    ax.yaxis.set_ticks_position('none')
    ax.xaxis.set_ticks_position('none')
    ax.set_xticks([])
    ax.set_yticks([])

    ax.set_xlabel(name, fontsize=13)
    ax.xaxis.set_label_coords(.30, 0.50)


def plot_name_BSS1(ax):
    plot_name(ax, "BSS-1")


def plot_name_BSS2(ax):
    plot_name(ax, "BrainScaleS-2")


def plot_psp_shapes(ax):
    # make the axis
    core.show_axis(ax)
    core.make_spines(ax)

    xvals = np.linspace(0., 100., 200)
    c_m = 0.2
    t_s = 10.
    w = 0.01
    t_i = 15.

    def theta(x):
        return x > 0

    def V(t, t_m):
        factor = 1.
        if t_m < t_s:
            factor = 6. / t_m

        t[t < t_i] = t_i
        if t_m != t_s:
            ret_val = factor * t_m * t_s / (t_m - t_s) * theta(t - t_i) * \
                (np.exp(-(t - t_i) / t_m) - np.exp(-(t - t_i) / t_s))
        else:
            ret_val = factor * theta(t - t_i) * np.exp(-(t - t_i) / t_m) * (t - t_i)

        ret_val[t < t_i] = 0.
        return ret_val

    taums = [100000000., 20, 10, 0.0001]
    taums_name = [r"\rightarrow \infty", "= 2", "= 1", r"\rightarrow 0"]
    colours = ['C7', 'C8', 'C9', 'C6']
    for t_m, t_m_name, col in zip(taums, taums_name, colours):
        # ax.set_xlabel(r'$\tau_\mathrm{m}$ [ms]')
        lab = "$" + r'\tau_\mathrm{{m}} / \tau_\mathrm{{s}} {}'.format(t_m_name) + "$"
        ax.plot(xvals, V(xvals.copy(), t_m), color=col, label=lab)

    ax.set_yticks([])
    ax.set_xticks([])

    ax.set_ylabel("PSPs [a. u.]")
    ax.yaxis.set_label_coords(-0.03, 0.5)

    ax.set_xlabel("time [a. u.]")
    ax.xaxis.set_label_coords(.5, -0.075)

    ax.legend(frameon=False)
